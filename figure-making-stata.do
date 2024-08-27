*************************************************************
// Project: Stata graphics -- SIMD workshop
// Author: Seth Watts
// Repository: https://github.com/sBwatts/figure-making-stata
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
ssc install catcibar, replace

* set your global! Or else Dani will yell at you. And I may yell at you too tbh.
global f "/Users/sethwatts/ASU Dropbox/Seth Watts/MAIN/All purpose .do files"	// denotes global f (you can label it whatever you want)

**# Graphics scheme
*Download @AsjadNaqvi's fantastic "schemepack" pack of schemes
ssc install schemepack, replace
graph query, schemes	// tells you the names of all the schemes you can try out

set scheme white_jet	// I personally love white_jet so that is what I will be using

**# Descriptive distributions
sysuse nlsw88, clear

* categorical bar graphs
graph bar (percent), over(industry)		// graph bar chart (display percent), by industry var -- x-axis not clear in figure, lets fix that

graph bar (percent), over(industry, label(angle(45)))	// for our industry var, lets angle the label at 45 degrees -- much better, lets fix up the y axis title

graph bar (percent), over(industry, label(angle(45))) ///
	ytitle("Percent", size(small)) title("Employment by Industry", size(small) pos(11))	// lets see what else is modifiable below

graph bar (percent), over(industry, label(angle())) /// 
	bar(1, col(black)) intensity(50) horizontal ///	// specify black bars, opacity of bar color to 50%, horizontal orientation
	ytitle("Percent", size(small)) title("Employment by Industry", size(small) pos(11))
	
	
* violinplot
violinplot wage ttl_exp tenure		// this is interesting but we can make it look better and there is a lot to do with this command suite

violinplot wage, over(collgrad)	mean(msymbol(X)) median(msymbol(d)) nobox nowhiskers // wage with college education as the sorting var, mean gets X symbol, median gets diamond symbol, no IQR box, no whiskers

// we can also sort by another variable of interest

violinplot wage, over(collgrad)	by(union) mean(msymbol(X)) median(msymbol(d)) nobox nowhiskers // wage with college education as the sorting var, by union status, mean gets X symbol, median gets diamond symbol, no IQR box, no whiskers

// alright, lets go all out for an example

violinplot wage, over(industry) vertical mean(msymbol(X)) median(msymbol(d)) nobox nowhiskers noline ///	// same as above + no outline
	xlab(, angle(45)) colors(economist) ///	// xlabel at 45 degrees, color set "economist"
	title("Wage Distribution by Employment Industry", size(small) pos(11)) note("Note: X = mean, Diamond = median", size(vsmall) pos(7))	// change title, add note
	
*category ci bar

**# Coefficient plots

* tables are fun and what not... kinda.. see?
est clear	// clear any stored estimates
eststo: reg wage ttl_exp collgrad c_city hours married age		// store estimates from reg model
esttab, replace ///
	 b(3) se(3) r2(3) label star(* 0.05 ** 0.01 *** 0.001) ///
	compress nonum ///
	title("Table 1. OLS Regression model") 

// if you like how I did this check out my table making github repository

* but figures are sometimes better. IMO coefficient plots are often underutilized. they can illustrate findings more succinctly
reg wage ttl_exp collgrad c_city hours married age

coefplot, ///
	mcolor(black) msymbol(T) ciopts(lcol(black)) ///
	drop(_cons) scheme(white_jet) xline(0) xtitle("Coefficients") ///
	coeflabels(collgrad = "College graduate (ref = non college graduate)" married = "Married (ref = non married)" c_city = "Lives center city (ref = non center city)") ///
	title("OLS Regression on Hourly Wages", size(small) pos(11))



**# Time series plots
* time series data (non - panel)
sysuse sp500, clear

tsset date		// indication that the data is time series -- date is the time variable

tsline open	// tsline is a command to create a line plot of a time series var, no need to specify the time variable since we did this above

// why the large drop? well....lets see where 9/11 is on the x-axis

tsline open, tline(11sept2001)		// we use tline in the tsline command suite, normally this is xline

// lets modify

gen date2 = date 	// statas numeric format of the date

tsline open, tline(11sept2001, lcol(red) lpat(solid)) text(1390 15262 "September 11th attacks", size(.2cm) box bcolor(gs15)) ytitle("S&P 500 opening price", size(small))		// same as above + vertical line on x-axis, color red, pattern solid, text at coordinates 1390(y-axis) 15262(x-axis: date numeric format), size of text, put a box around the text, color the box gs15, relabeling y axis

// maybe we want multiple x-axis lines

tsline open, tline(11sept2001, lcol(black) lpat(solid) lwidth(thin)) text(1390 15262 "September 11th attacks", size(.2cm) box bcolor(gs15)) tline(01apr2001, lcol(black) lpat(solid) lwidth(thin)) text(1390 15088 "April Fools Day", size(.2cm) box bcolor(gs15)) ytitle("S&P 500 opening price", size(small))	tlab(, angle(45))




**# Combining plots



