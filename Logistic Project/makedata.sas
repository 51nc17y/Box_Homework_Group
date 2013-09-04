libname AL "C:\Users\jwbox\Documents\IAA\Fall\Logistic Regression\Project";

PROC IMPORT OUT= BidHX 
            DATAFILE= "C:\Users\jwbox\Documents\IAA\Fall\Logistic Regression\Project\Construction Data.xls" 
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
  



PROC IMPORT OUT= FIRMA 
            DATAFILE= "C:\Users\jwbox\Documents\IAA\Fall\Logistic Regression\Project\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Engineering Firm A$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

DATA AL.FIRMA_TEST AL.FIRMA_VAL;
SET FIRMA;
  RAND = RANUNI(129);
  IF RAND < .85 THEN OUTPUT AL.FIRMA_TEST; ELSE OUTPUT AL.FIRMA_VAL;
RUN;



PROC IMPORT OUT= FIRMB
            DATAFILE= "C:\Users\jwbox\Documents\IAA\Fall\Logistic Regression\Project\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Engineering Firm B$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


DATA AL.FIRMB_TEST AL.FIRMB_VAL;
SET FIRMB;
  RAND = RANUNI(127);
  IF RAND < .85 THEN OUTPUT AL.FIRMB_TEST; ELSE OUTPUT AL.FIRMB_VAL;
RUN;