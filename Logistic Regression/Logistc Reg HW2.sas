data fludata; 
	set logistic.fludata; 
run; 

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

data fluother;
	set fludata; 
	where race='Other';
run;

proc print data=fluother; 
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

