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


DATA AL.BIDHX;
SET BIDHX;
  N_KEY_COMP = SUM(OF COMPETITOR_A -- COMPETITOR_J);
  LABEL N_KEY_COMP = "Number of Key Competitors Bidding";
RUN;
  



PROC IMPORT OUT= AL.FIRMA 
            DATAFILE= "C:\Users\jwbox\Documents\IAA\Fall\Logistic Regression\Project\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Engineering Firm A$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;



PROC IMPORT OUT= AL.FIRMB
            DATAFILE= "C:\Users\jwbox\Documents\IAA\Fall\Logistic Regression\Project\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Engineering Firm B$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

