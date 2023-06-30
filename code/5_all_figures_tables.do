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

global resultsFolder = "${CTC_Labor_git}/results"

cap mkdir "${CTC_Labor_git}/results"
cap mkdir "${CTC_Labor_git}/results/tables"

texdoc init "${resultsFolder}/all_figures_tables_new.tex", replace

/*tex

\documentclass[12pt]{article}
\usepackage{amsthm}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{setspace}
\usepackage[authoryear]{natbib}
\usepackage[margin=1in]{geometry}
\usepackage{color}
\usepackage{bbm}
\usepackage{booktabs}
\usepackage{pdflscape}
\usepackage{caption}
\usepackage{array}
\usepackage{subfig}
\usepackage{standalone}
\usepackage[countmax]{subfloat}
\usepackage[dvipsnames]{xcolor}
\PassOptionsToPackage{hyphens}{url}\usepackage[colorlinks=true,
	citecolor=blue,linkcolor=red,urlcolor=Maroon,
	breaklinks=true]{hyperref}

%\onehalfspacing
\doublespacing
\setlength{\parindent}{0.4in} %indentation space
\setlength{\footnotesep}{0.3cm} %vertical space between footnotes

\begin{document}

\title{ \textbf{The Short-Term Labor Supply Response to the Expanded Child Tax 
Credit.}\thanks{
Enriquez: Maassachusetts Institute of Technology, enriquez@mit.edu. 
Jones: University of Chicago, damonjones@uchicago.com. Tedeschi: 
ernie.tedeschi@gmail.com.}\\All Figures and Tables}

\date{}

\maketitle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% FIGURES

%% Figure 1: H1 H2 2021 & H2 2021 H1 2022
\begin{figure}
\centering
\caption{Relationship between ARP Child Tax Credit Eligibility and 
	Labor Force Participation}\label{fig:main}

Panel A. Before/After Extended CTC Introduction

\includegraphics[scale = 0.75]{figures/LFPR_H1_H2_2021_new.pdf}

Panel B. Before/After Extended CTC Expiration

\includegraphics[scale = 0.75]{figures/LFPR_H2_2021_H1_2022_new.pdf}

\raggedright
\footnotesize
    This figure shows the relationship between ARP CTC eligibility and labor 
	force participation. Panel A shows the relationship before (Feb-June 2021) 
	versus after (Aug-Dec 2021) the introduction of the ARP CTC benefit. 
	Panel B shows the relationship before (Aug-Dec 2021) versus after 
	(Jan-Mar 2022) the expiration of the ARP CTC benefit.
\end{figure}

\clearpage

%% Figure 2: H1 H2 2019 & H2 2019 H1 2020
\begin{figure}
\centering

\caption{Relationship between Placebo ARP Child Tax Credit Eligibility and 
	Labor Force Participation: 2019}\label{fig:placebo}

Panel A. Before/After Extended CTC Introduction: Placebo (2019)

\includegraphics[scale = 0.75]{figures/LFPR_H1_H2_2019_new.pdf}

Panel B. Before/After Extended CTC Expiration: Placebo (2019)

\includegraphics[scale = 0.75]{figures/LFPR_H2_2019_H1_2020_new.pdf}

\raggedright
\footnotesize
    This figure shows the relationship between placebo ARP CTC eligibility 
	(in 2019) and labor force participation. Panel A shows the relationship 
	before (Feb-June 2019) versus after (Aug-Dec 2019) the placebo equivalent 
	of the introduction of the ARP CTC benefit. Panel B shows the relationship 
	before (Aug-Dec 2021) versus after (Jan-Mar 2022) the placebo equivalent of 
	the introduction of the ARP CTC benefit. 

\end{figure}

\clearpage

%% Figure 3: Heterogeneity
\begin{figure}
\begin{center}

\caption{Effect of ARP Child Tax Credit Extension on Labor Force Participation 
	and Total Hours Worked}\label{fig:heterogeneity}


\includegraphics[scale = 0.8]{figures/LFPR_Hours_Heterogeneity_new.eps}
\end{center}

\raggedright
\footnotesize
    This figure shows the effect of the ARP CTC eligibility percentile on labor 
	force participation and hours. The dependent variable is scaled by its 
	standard deviation. Specification detailed in the text. Standard errors 
	are clustered by region and household size.
\end{figure}

\clearpage

%%% TABLES 

% Table 1
\input{tables/tab_main.tex}

\end{document}

tex*/

texdoc close
