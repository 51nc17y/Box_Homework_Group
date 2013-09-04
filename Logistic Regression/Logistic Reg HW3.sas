
%let PATH=C:\Users\Phill\Documents\GitHub\Box_Homework_Group\Logistic Regression; 

proc import datafile="&PATH\fludata_new.xlsx" 
			out=flu
			dbms=excel
			replace; 
run; 

data Flu;
	set Flu;
if Income = 'Low' then IncLevel = 1;
else if Income = 'Medium' then IncLevel = 2;
else if Income = 'High' then IncLevel = 3;
run;

data Flu;
	set Flu;
	if race = 'Hispanic' then race = 'Other'; 
run; 

proc logistic data=flu 
	plots(only label unpack)=(leverage dfbetas dpc influence); 
	class 	race(param=effect ref='Other') 
			income(param=reference ref='High') 
			gender(param=reference ref='Female')
			previous(param=reference ref='No');
			/*GEN:model 	flu(event='Yes') = gender / clodds=PL;*/
			/*INC:model 	flu(event='Yes') = gender income / clodds=PL;*/
			/*ALL:model 	flu(event='Yes') = gender income race previous age distance visits /selection=backwards clodds=PL;*/
			MAIN:	model 	flu(event='Yes') = gender  income race/ clodds=PL;
	output 	out=predict p=pred; 
run;  
