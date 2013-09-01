libname AAEM  "C:\Users\jwbox\Documents\IAA\Fall\Data Mining\Data";


DATA DEER;
SET AAEM.DEER;
  P = DEER / (DEER + NONDEER);
  label date = "Date of Accident"
  p = "Prob. the Accident Involved Deer";

  RUN;

TITLE "Accidents Involving Deer";   
 PROC SGPLOT DATA = DEER;
   SERIES Y = DEER X = date;
run;

TITLE "Probability the Accident Involved Deer";  
 PROC SGPLOT DATA = DEER;
   SERIES Y = P X = date;
run;

/* Question 2 */
proc reg data= deer plots(only)=(rsquare adjrsq cp);
    DEER: model deer = t mon1 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11 mon12;
    title 'Deer regressed on Mon1 - Mon12 and t';
run;
quit;

/* Question 3 */
proc reg data= deer;
    DEER: model deer = t mon1 mon2 mon3 mon4 mon5 mon6 mon7 mon8 mon9 mon10 mon11;
    title 'Deer regressed on Mon1 - Mon11 and t';
run;
quit;

