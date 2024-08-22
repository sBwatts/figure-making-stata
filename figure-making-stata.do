*************************************************************
// Project: Stata graphics -- SIMD workshop
// Author: Seth Watts
*************************************************************
*Awesome resource to check out different types of stata graphics: https://medium.com/the-stata-gallery/top-25-stata-visualizations-with-full-code-668b5df114b6

**# Packages
ssc install coefplot, replace
ssc install ciplot, replace
ssc install violinplot, replace
ssc install dstat, replace
ssc install moremata, replace
ssc install colrspace, replace
ssc install palettes, replace
ssc install labutil, replace

* set your global! Or else Dani will yell at you. And I may yell at you too tbh.
global f "/Users/sethwatts/ASU Dropbox/Seth Watts/MAIN/All purpose .do files"	// denotes global f (you can label it whatever you want)

**# Graphics scheme
*Download @AsjadNaqvi's fantastic "schemepack" pack of schemes
ssc install schemepack, replace
graph query, schemes	// tells you the names of all the schemes you can try out

set scheme white_jet	// I personally love white_jet so that is what I will be using

**# Descriptive distributions
sysuse nlsw88, clear


**# Time series plots
sysuse sp500, clear


**# Coefficient plots

* tables are fun and what not... kinda.. see?

< reg table >	// if you like how I did this check out my table making github repository

* but figures are sometimes better

< reg coef figure >		// now that's cool


**# Combining plots
