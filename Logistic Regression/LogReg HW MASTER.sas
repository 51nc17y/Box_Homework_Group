/*Your Windows USer Name goes here*/
%let user=Phill;

***********************************************************************************
* 			                     HOMEWORK PART I                                  +
***********************************************************************************

;ods all close;
libname Logistic "C:\Users\&user\Documents\GitHub\Box_Homework_Group\Logistic Regression";

libname Logxlsx "C:\Users\&user\Documents\GitHub\Box_Homework_Group\Logistic Regression\FluData.xlsx";

data Logistic.fludata;
	set Logxlsx."Sheet1$"n;
run;

proc contents data=Logistic.fludata varnum;
run;

/*Create a contingency table that compares the variables Flu and Gender. 
What is the odds ratio for the relationship between these two variables? 
Is this a significant relationship?*/

ods graphics on;

proc freq data=Logistic.fludata nlevels;
	tables Gender*Flu / chisq measures plots(only)=freqplot 
                              (type=barchart scale=percent orient=vertical twoway=stacked);
title 'Contingency Table for Flu and Gender';
run;

/* The odds ratio is 2.6005. The CI is (1.6401, 4.1234).
This means that Females are 2.6 times the odds more likely to have NO FLU
than Males.

From all tests, this is significant. But since we have binary vs. binary,
or ordinal vs. ordinal, we check the Mantel-Haenszel. This is p<.0001 
Also, the oddsratio CI does not contain 1. */

/*************************************************************************/

/*Calculate the appropriate statistic to detect an association between the variables 
Income and Flu and summarize your results in terms of the problem.*/

/*Calculate the appropriate statistic to measure the strength of an association between 
the variables Income and Flu and summarize your results in terms of the problem.*/

/* NEED TO CODE IN 1, 2, 3 FOR LOW, MEDIUM, HIGH */
data Logistic.fludata;
	set Logistic.fludata;
if Income = 'Low' then IncLevel = 1;
else if Income = 'Medium' then IncLevel = 2;
else if Income = 'High' then IncLevel = 3;
run;


proc freq data=Logistic.fludata nlevels;
	tables IncLevel*Flu / all;
title 'Tests for Association for Flu and Income';
run;

/* Using Mantel-Haenszel since they are both Ordinal variables.
p = 0.7633 so there is no significant relationship. */

/* Using Spearman correlation, the value is 0.0263. This backs it up*/

/*********************************************************************/

/* Conduct a stratified analysis on Gender and Flu controlling for Income. 
Calculate the adjusted (common) odds ratio and compare this to your previous results. 
Does there appear to be a problem with confounding? */

proc freq data=Logistic.fludata;
	tables IncLevel*Flu*Gender / all plots(only)=oddsratioplot(stats);
	title 'Controlling for Income';
run;

/*proc freq data=Logistic.fludata;
	tables Income*Flu*Gender / all plots(only)=oddsratioplot(stats);
	title 'Controlling for Income';
run;*/

/* The adjusted odds ratio is 2.52 with a CI of (1.58, 4.00). 
Since this contains the 'uncontrolled' odds ratio of 2.60, 
we conclude there is no confounding.*/


/* Conduct a stratified analysis on Gender and Flu controlling for Income. 
Is there a potential problem with quasi-complete separation in the data 
if we were to include an interaction between Gender and Income?
THIS QUESTION HAS BEEN REMOVED FROM HOMEWORK*/

ods html open;
ods listing open;

proc freq data=Logistic.fludata nlevels;
   tables Gender*Flu/ chisq measures plots(only)=freqplot 
                              (type=barchart scale=percent orient=vertical twoway=stacked);
   tables IncLevel*Gender*Flu / all bdt plots(only)=oddsratioplot(stats); 
   exact zelen;
   title 'Possible Interaction';
run;

proc freq data=Logistic.fludata nlevels;
   tables Flu*Gender/ chisq measures plots(only)=freqplot 
                              (type=barchart scale=percent orient=vertical twoway=stacked);
   tables IncLevel*Flu*Gender / all bdt plots(only)=oddsratioplot(stats); 
   exact zelen;
   title 'Possible Interaction';
run;
/* 
This says that there is some significant relationship after accounting
for the IncLevel.

This also says according to Breslow-Day and Zelen that there is no significant
interaction terms.

There is a difference in Gender and Flu after accounting for IncLevel.

But there is no difference in the relationships between Gender and Flu 
across different income levels.
(It is the same amongst all levels of income - only the gender matters)
*/

/* Logistic Model with all variables */
proc logistic data=Logistic.fludata plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
		Income(param=ref ref='High')
		Previous(param=ref ref='No')
		Race (ref='Other');
	model flu(event='Yes') = Race Income Gender Previous Age Distance Visits / 
			clodds=pl;
	units Age=10;
	title 'All Variables Flu Logistic Model';
run;

/* Only Gender seems significant or relevant. */
/* Whole model is significant. */

/* Try the model with only Gender and/or Income*/
proc logistic data=Logistic.fludata plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female');
	model flu(event='Yes') = Gender  / clodds=pl;
	title 'Gender Only Flu Logistic Model';
run;

proc logistic data=Logistic.fludata plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
			income(param=ref ref='High');
	model flu(event='Yes') = Gender Income  / clodds=pl;
	title 'Gender and Income Flu Logistic Model';
run;

/* Checking for Assumptions */
data logistic.flu2;
	set logistic.fludata;
sage=age*log(age);
sdistance=distance*log(distance);
svisits=visits*log(visits);
run;

proc logistic data=Logistic.flu2 plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
		IncLevel(param=ref ref='3')
		Previous(param=ref ref='No')
		Race (ref='Other');
	model flu(event='Yes') = Race IncLevel Gender Previous Age sage Distance sdistance 
		Visits svisits / clodds=pl;
	units Age=10;
	title 'checking assumptions Flu Logistic Model';
run;

/* Stepwise selection*/
proc logistic data=Logistic.fludata plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
		IncLevel(param=ref ref='3')
		Previous(param=ref ref='No')
		Race (ref='Other');
	model flu(event='Yes') = Race IncLevel Gender Previous Age Distance Visits / 
			clodds=pl selection=stepwise slentry=.3 slstay=.35 details lackfit;
	units Age=10;
	title 'Stepwise Flu Logistic Model';
run;

/* Backward selection */
proc logistic data=Logistic.fludata plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
		IncLevel(param=ref ref='3')
		Previous(param=ref ref='No')
		Race (ref='Other');
	model flu(event='Yes') = Race IncLevel Gender Previous Age Distance Visits / 
			clodds=pl selection=backward details lackfit;
	units Age=10;
	title 'Backward Selection Flu Logistic Model';
run;
title; 
***********************************************************************************
* 			                     HOMEWORK PART II                                 +
***********************************************************************************

Set temporary dataset to work with;
data fludata; 
	set logistic.fludata; 
run; 


/*Checking for Quasi-Complete Seperation (cell counts that 0 in the entire class*/

/*SAS assigns a probability of zero to an outcome. However, the logistic function never actually reaches zero.  */
/*High parameter estimates and high SE are warning signs. (SAS tries to reach zero, but cannot, thus is quits at some point) */

/*Identified Race='Other' as a case of QCS*/
proc logistic data=fludata
	plots(only)= (effect(clband showobs) oddsratio); 
	class 	race(param=effects ref='Other') 
			income(param=reference ref='High') 
			gender(param=reference ref='Female')
			previous(param=reference ref='No');
/*GEN:model 	flu(event='Yes') = gender / clodds=PL;*/
/*INC:model 	flu(event='Yes') = gender income / clodds=PL;*/
/*ALL:model 	flu(event='Yes') = gender income race previous age distance visits /selection=backwards clodds=PL;*/
TEST:	model 	flu(event='Yes') = gender  income race/ clodds=PL;
run;  

proc print data=fluother; 
	where race='Other';
run; **two observations with "Other" as race;

/*Merging Hispanic obs into Other*/

data Flu2;
	set fludata;
	if race = 'Hispanic' then race = 'Other'; 
run; 

/*Checking if that worked out*/
proc freq data=flu2; 
	tables race; 
run; 

proc logistic data=flu2
	plots(only)= (effect(clband showobs) oddsratio); 
	class 	race(param=effects ref='Other') 
			income(param=reference ref='High') 
			gender(param=reference ref='Female')
			previous(param=reference ref='No');
/*GEN:model 	flu(event='Yes') = gender / clodds=PL;*/
/*INC:model 	flu(event='Yes') = gender income / clodds=PL;*/
/*ALL:model 	flu(event='Yes') = gender income race previous age distance visits /selection=stepwise clodds=PL;*/
TEST:	model 	flu(event='Yes') = gender  income race/ clodds=PL;
run;  

/*Model improves slightly as to test stats, concordant pairs virtually uneffected, race becomes significant at an alpha=.05
African Americans have 1.964 (twice) the odds of getting the new flu compared to the overall average population. 

when ref level changes so does odds ratio - why?



Males have 2.6 the odds of getting the new flu when compared to females. 
*/

/*Rechecking Model Assumptions (SImilar to SAS code as above*/


/* Checking for Assumptions */
data flu3;
	set flu2;

	sage=age*log(age);
	sdistance=distance*log(distance);
	svisits=visits*log(visits);

	if Income = 'Low' then IncLevel = 1;
	else if Income = 'Medium' then IncLevel = 2;
	else if Income = 'High' then IncLevel = 3;

run;

proc freq data=flu3 nlevels;
   tables Gender*Flu/ chisq measures plots(only)=freqplot 
                              (type=barchart scale=percent orient=vertical twoway=stacked);
   tables IncLevel*Gender*Flu / all bdt plots(only)=oddsratioplot(stats); 
   exact zelen;
   title 'Possible Interaction after merging Hispanics and Others';
run;

/*Tests for Homogeneity of Odds Ratios */
/*Breslow-Day-Tarone Chi-Square 3.9681 */
/*DF 2 */
/*Pr > ChiSq 0.1375 */
/*    */
/*Zelen's Exact Test (P) 0.0099 */
/*Exact Pr <= P 0.1380 */

/*NOT ENOUGH EVIDENCE FOR INTERACTIONS*/
/*There is not enough evidence to say there is a difference in Odds Ratios. Therefore there is NO interaction and the Odds Ratios stay about the same for every level.*/



proc logistic data=flu3 plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
		IncLevel(param=ref ref='3')
		Previous(param=ref ref='No')
		Race (ref='Other');
	model flu(event='Yes') = Race IncLevel Gender Previous Age sage Distance sdistance 
		Visits svisits / clodds=pl;
	units Age=10;
	title 'checking assumptions Flu Logistic Model after merging Hispanics and Other';
run;

/* Stepwise selection*/
proc logistic data=flu3 plots(only)=(effect(clband showobs) oddsratio);
	class gender(param=ref ref='Female')
		IncLevel(param=ref ref='3')
		Previous(param=ref ref='No')
		Race (ref='Other');
	model flu(event='Yes') = Race IncLevel Gender Previous Age Distance Visits / 
			clodds=pl selection=stepwise slentry=.3 slstay=.35 details lackfit;
	units Age=10;
	title 'Stepwise Flu Logistic Model after merging Hispanics and Other';
run;

/* Backward selection */
/*proc logistic data=flu3 plots(only)=(effect(clband showobs) oddsratio);*/
/*	class gender(param=ref ref='Female')*/
/*		IncLevel(param=ref ref='3')*/
/*		Previous(param=ref ref='No')*/
/*		Race (ref='Other');*/
/*	model flu(event='Yes') = Race IncLevel Gender Previous Age Distance Visits / */
/*			clodds=pl selection=backward details lackfit;*/
/*	units Age=10;*/
/*	title 'Backward Selection Flu Logistic Model after merging Hispanics and Other';*/
/*run;*/

/*checking for Goodness-of-fit with Hosmer-Lemeshow test*/

proc logistic data=flu3 plots(only)=(effect(clband showobs) oddsratio); 
	class 	gender 		(param=ref ref='Female')
			IncLevel 	(param=ref ref='3')
			Race		(param=effects ref='Other'); 
	model	flu(event='Yes')= Gender age / clodds = pl details lackfit rsq;
	title 'Model with all significant variables at a 5% level'; 
run; 

/*Partition for the Hosmer and Lemeshow Test */
/*Group Total Flu = Yes Flu = No  */
/*Observed Expected Observed Expected */
/*1 26 4 3.61 22 22.39 */
/*2 37 8 5.52 29 31.48 */
/*3 8 1 1.73 7 6.27 */
/*4 81 20 20.17 61 60.83 */
/*5 30 8 8.18 22 21.82 */
/*6 28 4 8.69 24 19.31 */
/*7 33 12 13.23 21 19.77 */
/*8 69 34 31.70 35 37.30 */
/*9 35 22 20.18 13 14.82 */
/**/
/**/
/**/
/*Hosmer and Lemeshow Goodness-of-Fit*/
/*Test */
/*Chi-Square DF Pr > ChiSq */
/*6.3090 7 0.5042 */

/*Problmens in group 	4 (total<10, expected<2) only 9 groups?*/
/*Test verifies that there is no difference between ours and the */
/*fully saturated model proposed by the test*/

/*R-Square 0.0835 Max-rescaled R-Square 0.1165 */

proc logistic data=flu3 plots(only)=(effect(clband showobs) oddsratio); 
	class 	gender 		(param=ref ref='Female');
	model	flu(event='Yes')= Gender / clodds = pl lackfit rsq;
	title 'Gender Model'; 
run; 

/*Hosmer and Lemeshow Goodness-of-Fit
Test 
Chi-Square DF Pr > ChiSq 
0.0000 0 >>>> si tge nidek IS different than the saturated model>>

*******PROBLEM!!!!!!**********

/*R-Square 0.0477 Max-rescaled R-Square 0.0665 */

***************ROC OUR MODEL***********************; 

proc logistic data=flu3; 
	class 	gender	(param=ref ref='Female') 
			inclevel(param=ref ref='3')
			race	(param=effects ref='Other')
			Previous(param=ref ref='No'); 
	model 	flu(event='Yes') = Race IncLevel Gender Previous Age Distance Visits; 
	ROC		'Just Gender'	Gender; 
/*	ROC 	'Income Race' 	inclevel race; */
/*	ROC		'Gender Income'	Gender IncLevel; */
/*	ROC		'RAce Gender'	Gender Race; */
	ROC		'Gender, Rsce, Income' Gender Race IncLevel; 
	ROCcontrast / estimate=allpairs; 
	title 'Comparing ROC Curves'; 
run; 

/*Gender, Income and Gender, Income, Race are the only ones that are not different */
/*from Full Model's performance. */
title 'Youden Index';
proc logistic data=flu3; 
	class 	gender	(param=ref ref='Female') 
			inclevel(param=ref ref='3')
			race	(param=effect ref='Other');
	model 	flu(event='Yes') = Gender Inclevel Race / outroc=ROC;
run; 

proc print data=roc; 
run;  

data Youden; 
	set Roc;
	Spec = abs(_1mspec_-1);
	J = _sensit_+spec-1;
run; 

proc print data=Youden; 
run;  

/*Obs _PROB_ _POS_ _NEG_ _FALPOS_ _FALNEG_ _SENSIT_ _1MSPEC_   Spec 	    J */
/*5  0.40107   61   183     51       52    0.53982   0.21795 0.78205 0.32187 */

title 'Classification Table with Cutoff .32187'; 
proc logistic data=flu3; 
	class 	gender	(param=ref ref='Female') 
			inclevel(param=ref ref='3')
			race	(param=effect ref='Other');
	model 	flu(event='Yes') = Gender Inclevel Race / ctable pprob=0.40;
run; 


***********************************************************************************
* 			                     HOMEWORK PART III                                +
***********************************************************************************
