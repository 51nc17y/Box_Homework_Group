%let PATH = C:\Users\Phill\Documents\GitHub\Box_Homework_Group\Logistic Project;

libname AL "&path";

PROC IMPORT OUT= BidHX 
            DATAFILE= "&path\Construction Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Bid History$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


DATA AL.BID_TEST AL.BID_VAL ;
SET BIDHX (rename=(Estimated_Cost__Millions_=est_cost estimated_years_to_complete=est_years cost_after_engineering_estimate_=est_eng  region_of_country=region Winning_Bid_Price=Win_Price number_of_competitor_bids=num_bids));
  N_KEY_COMP = SUM(OF COMPETITOR_A -- COMPETITOR_J);
  RAND = RANUNI(12345);
  IF RAND < .85 THEN OUTPUT AL.BID_TEST; ELSE OUTPUT AL.BID_VAL;
  DROP RAND;
  LABEL N_KEY_COMP = "Number of Key Competitors Bidding";
RUN;
  

PROC IMPORT OUT= FIRMA 
            DATAFILE= "&path\Construction Data.xls" 
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
            DATAFILE= "&path\Construction Data.xls" 
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

PROC FORMAT; 
	VALUE SECTORFMT
	1	=  	'Transportation'
	2	=	'Lodging'
	3	=  	'Multi-family Residential'
	4	=	'Amusement and Recreation'
	5	=	'Highway and Street'
	6	=  	'Education'
	7  	=	'Healthcare'
	8  	=	'Manufacturing'
	9  	=	'Power'
	10  =	'Military';
	11	=	'Power or Manufacturing'; 
RUN; 

DATA AL.BID_VAL;
	SET AL.BID_VAL; 
	FORMAT SECTOR SECTORFMT.; 
RUN;

DATA AL.FIRMA_VAL;
	SET AL.FIRMA_VAL; 
	FORMAT SECTOR SECTORFMT.; 
RUN; 

DATA AL.FIRMB_VAL;
	SET AL.FIRMB_VAL; 
	FORMAT SECTOR SECTORFMT.; 
RUN;  

DATA AL.BID_TEST;
	SET AL.BID_TEST; 
	FORMAT SECTOR SECTORFMT.; 
RUN;

DATA AL.FIRMA_TEST;
	SET AL.FIRMA_TEST; 
	FORMAT SECTOR SECTORFMT.; 
RUN; 

DATA AL.FIRMB_TEST;
	SET AL.FIRMB_TEST; 
	FORMAT SECTOR SECTORFMT.; 
RUN;  
