
/*Put your folder directory here where you saved Construction Data.xls; */
%LET PATH = C:\Users\Phill\Documents\GitHub\Box_Homework_Group\Logistic Project; 

libname AL "&PATH";

PROC IMPORT OUT= BidHX 
            DATAFILE= "&PATH\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Bid History$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


DATA AL.BIDHX;
SET BIDHX;
  N_KEY_COMP = SUM(OF COMPETITOR_A -- COMPETITOR_J);
  LABEL N_KEY_COMP = "Number of Key Competitors Bidding";
RUN;
  



PROC IMPORT OUT= AL.FIRMA 
            DATAFILE= "&PATH\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Engineering Firm A$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;



PROC IMPORT OUT= AL.FIRMB
            DATAFILE= "&PATH\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Engineering Firm B$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

/*Creating the Validation Set*/

/*RANUNI gives a random number from 0 to 1.  the value in the () is the seed; if we all use the same seed, we will get the same records in test and bid*/

PROC IMPORT OUT= BidHX 
            DATAFILE= "&PATH\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Bid History$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


DATA AL.BID_TEST AL.BID_VAL;
SET BIDHX;
  N_KEY_COMP = SUM(OF COMPETITOR_A -- COMPETITOR_J);
  RAND = RANUNI(12345);
  IF RAND < .85 THEN OUTPUT AL.BID_TEST; ELSE OUTPUT AL.BID_VAL;
  DROP RAND;
  LABEL N_KEY_COMP = "Number of Key Competitors Bidding";
RUN;
