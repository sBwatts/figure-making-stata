*************************************************************
// Project: Stata graphics -- SIMD workshop
// Author: Seth Watts
// Repository: https://github.com/sBwatts/figure-making-stata
*************************************************************
*Awesome resource to check out different types of stata graphics: https://medium.com/the-stata-gallery/top-25-stata-visualizations-with-full-code-668b5df114b6

**# Packages
// plot types
ssc install coefplot, replace
ssc install ciplot, replace
ssc install cibar, replace
ssc install violinplot, replace
ssc install catcibar, replace

// colors and palettes
ssc install dstat, replace
ssc install moremata, replace
ssc install colrspace, replace
ssc install palettes, replace
ssc install labutil, replace


* set your global!
global f "/Users/sethwatts/ASU Dropbox/Seth Watts/MAIN/All purpose .do files/figure-making-stata"	// denotes global f (you can label it whatever you want)

**# Graphics scheme
*Download @AsjadNaqvi's fantastic "schemepack" pack of schemes
ssc install schemepack, replace
graph query, schemes	// tells you the names of all the schemes you can try out

set scheme white_jet	// I personally love white_jet so that is what I will be using

**# Descriptive distributions
sysuse nlsw88, clear	// load in data

*kdensity plots
kdensity wage if collgrad == 0
kdensity wage if collgrad == 1, addplot(kdensity wage if collgrad == 0) 

kdensity wage if collgrad == 1, addplot(kdensity wage if collgrad == 0) legend(order(1 "Wage, no college grad" 2 "Wage, college grad") pos(3) ring(0) region(fcolor(gs15))) title("Kernal Density Plot", pos(11) size(small)) note(, size(vsmall) span)


* categorical bar graphs
graph bar (percent), over(industry)		// graph bar chart (display percent), by industry var -- x-axis not clear in figure, lets fix that

graph bar (percent), over(industry, label(angle(45)))	// for our industry var, lets angle the label at 45 degrees -- much better, lets fix up the y axis title

graph bar (percent), over(industry, label(angle(45))) ///
	ytitle("Percent", size(small)) title("Employment by Industry", size(small) pos(11))	// lets see what else is modifiable below

graph bar (percent), over(industry, label(angle())) /// 
	bar(1, color(red)) ///
	intensity(50) horizontal ///	// specify black bars, opacity of bar color to 50%, horizontal orientation
	ytitle("Percent", size(small)) title("Employment by Industry", size(small) pos(11))
	
	
* violinplot
violinplot wage ttl_exp tenure		// this is interesting but we can make it look better and there is a lot to do with this command suite

violinplot wage, over(collgrad)	mean(msymbol(X)) median(msymbol(d)) nobox // wage with college education as the sorting var, mean gets X symbol, median gets diamond symbol, no IQR box, no whiskers

// we can also sort by another variable of interest

violinplot wage, over(collgrad)	by(union) mean(msymbol(X)) median(msymbol(d)) nobox nowhiskers // wage with college education as the sorting var, by union status, mean gets X symbol, median gets diamond symbol, no IQR box, no whiskers

// alright, lets go all out for an example

violinplot wage, over(industry) vertical mean(msymbol(X)) median(msymbol(d)) nobox noline ///	// same as above + no outline
	xlab(, angle(45)) colors(economist) ///	// xlabel at 45 degrees, color set "economist"
	title("Wage Distribution by Employment Industry", size(small) pos(11)) note("Note: X = mean, Diamond = median", size(vsmall) span)	// change title, add note
	
*category ci plot
* displays means and confidence intervals
ciplot wage, by(collgrad)

ciplot wage, by(collgrad) msymbol(d) mcol(black) rcap(lcol(black)) note(, size(vsmall))	// diamond symbol, symbol color, confidence int color, change note size

*category ci bar
// see: https://medium.com/the-stata-gallery/advanced-bar-graphs-in-stata-part-1-means-with-confidence-intervals-2dd9d3b399b4
cibar wage, over(collgrad)	// looks very average lets make it better

cibar wage, over(collgrad) ///
	barcolor(blue%65 red%65) ciopts(lcol(black%75)) ///
	/*barlab(on) blfmt(%4.1f) blsize(vsmall) blposition(swest) blcolor(white) */ ///
	graphopts(ytitle("Mean Hourly Wage") ylab(0(3)12) note("Note: 95% confidence intervals", size(vsmall) span))

// now lets sort by two variables, race and education using the over command

cibar wage, over(collgrad race) ///
	barcolor(blue%65 red%65) ciopts(lcol(black%75)) ///
	barlab(on) blfmt(%4.1f) blsize(vsmall) blposition(swest) blcolor(white) ///
	graphopts(ytitle("Mean Hourly Wage") ylab(0(2)16) note("Note: 95% confidence intervals", size(vsmall) span))

**# Coefficient plots

* tables are fun and what not... kinda.. see?
est clear	// clear any stored estimates
eststo: reg wage ttl_exp collgrad c_city hours married age		// store estimates from reg model
esttab, replace ///
	b(3) se(3) r2(3) label star(* 0.05 ** 0.01 *** 0.001) ///
	nonum ///
	title("Table 1. OLS Regression model") 

// if you like how I did this check out my table making github repository

* but figures are sometimes better. IMO coefficient plots are often underutilized. they can illustrate findings more succinctly
reg wage ttl_exp collgrad c_city hours married age

coefplot, ///
	mcolor(black) msymbol(T) ciopts(lcol(black)) /// //marker options and CI options
	drop(_cons) scheme(white_jet) xline(0) xtitle("Coefficients") ///	// drop constant, set scheme, x-axis line, x-axis title
	coeflabels(collgrad = "College graduate (ref = non college graduate)" married = "Married (ref = non married)" c_city = "Lives center city (ref = non center city)") ///	// renaming coefficient labels
	title("OLS Regression on Hourly Wages", size(small) pos(11))	// plot title, size of title and position
	
// You can also categorize the coefplot -- say you are interested in the above reg model but by union status
reg wage ttl_exp collgrad c_city hours married age if union == 0
est store nonunion	// store estimates
reg wage ttl_exp collgrad c_city hours married age if union == 1
est store union	// store estimates

coefplot (nonunion, label("Non-union") mcolor(blue) mlcolor(blue) msymbol(d) /// // options for first estimates
	ciopts(lcol(blue))) /// // CI options for first estimates
	(union, label("Union") mcolor(gs7) mlcolor(gs7) msymbol(s) /// // options for second estimates
	ciopts(lcol(gs7))), /// // CI options for second estimates
	drop(_cons) xline(0, lcol(red) lpat(dash)) scheme(white_jet) xtitle("Coefficients") /// // same as above, drop constant, provide a vertical line on x axis at 0, make it red and dashed, scheme set and x title specified
	coeflabels(collgrad = "College graduate (ref = non college graduate)" married = "Married (ref = non married)" c_city = "Lives center city (ref = non center city)") /// // label vars
	title("OLS Regression on Hourly Wages", size(small) pos(11)) /// // title
	note("95% Confidence Intervals Displayed", size(vsmall) span) // add note

**# Margins plot
// see: https://medium.com/the-stata-gallery/combined-marginsplots-for-regression-analysis-in-stata-b107b5f237fc

reg wage ttl_exp i.collgrad c_city hours i.married age

margins, at(ttl_exp=(0(2)22)) level(95)		// calling the margins for our experience var

marginsplot, /// main marginsplot command
scheme(white_jet) /// change graph scheme
plotopts(lwidth(medthick) lcolor(black%70) msize(med) mcolor(black%75) mlcolor(black)) /// changes fit line and marker features
recastci(rarea) ciopts(fcolor(gs15) lcolor(gs15)) /// options for CI area opacity and line colors
title("{bf}Experience and Hourly Wages", pos(12) size(small)) /// makes title, and spans it across graph (looks nicer)
xsize(6.5) ysize(4.5) /// makes width of graph 6.5 inches, and height of graph 4.5 inches
xlab(, glcolor(gs15) glpattern(solid)) /// adds solid light gray vertical grid lines
ylab(, glcolor(gs15) glpattern(solid)) /// adds solid light gray horizontal grid lines
ytitle(Hourly Wage) /// title of y-axis
note("Note: Model controls for education, working in the city, usual hours worked, marriage status, and age; n=2242", size(vsmall) span) // adds note; "span" places in left corner //

**# Time series plots
* time series data (non - panel)
sysuse sp500, clear

tsset date		// indication that the data is time series -- date is the time variable

tsline open	// tsline is a command to create a line plot of a time series var, no need to specify the time variable since we did this above

// why the large drop? well....lets see where 9/11 is on the x-axis

tsline open, tline(11sept2001)		// we use tline in the tsline command suite, normally this is xline

// lets modify

gen date2 = date 	// statas numeric format of the date

tsline open, tline(11sept2001, lcol(red) lpat(dash)) text(1390 15262 "September 11th attacks", size(.2cm) box bcolor(gs15)) ytitle("S&P 500 opening price", size(small))		// same as above + vertical line on x-axis, color red, pattern dash, text at coordinates 1390(y-axis) 15262(x-axis: date numeric format), size of text, put a box around the text, color the box gs15, relabeling y axis

// maybe we want multiple x-axis lines

tsline open, tline(11sept2001, lcol(black) lpat(dash) lwidth(thin)) text(1390 15262 "September 11th attacks", size(.2cm) box bcolor(gs15)) tline(04jul2001, lcol(black) lpat(dash)) ytitle("S&P 500 opening price", size(small)) text(1390 15187 "Independence Day", size(.2cm) box bcolor(gs15)) tlab(, angle(45)) title("(A)", size(small) pos(11))

graph save "$f/open-line.gph", replace

**# Combining plots
* say we want to plot the line graph of the opening and closing prices. We see that it is highly correlated visually but we want to add a scatter plot that indicates the pearson's r value

corr open close		// get the r value

scatter open close, mcol(blue red) scheme(white_jet) text(1250 1320 "r = 0.98", size(.3cm) box bcolor(gs15)) title("(B)", size(small) pos(11))
graph save "$f/scatter.gph", replace

tsline open close, lcolor(blue red) tline(11sept2001, lcol(black) lpat(dash) lwidth(thin)) text(1390 15262 "September 11th attacks", size(.2cm) box bcolor(gs15)) tline(04jul2001, lcol(black) lpat(dash)) ytitle("S&P 500 opening price", size(small)) text(1390 15187 "Independence Day", size(.2cm) box bcolor(gs15)) tlab(, angle(45)) title("(A)", size(small) pos(11)) legend(pos(7) ring(0) region(fcolor(gs15)))

graph save "$f/open-close-line.gph", replace

graph combine "$f/open-close-line" "$f/scatter.gph" , col(1) note("Note: data from 'sysuse sp500' in Stata", size(vsmall))	// combine the graphs that you saved through your global, one column, add note

graph export "$f/combined-plot.jpg", replace

**# Live example walk through

sysuse lifeexp
