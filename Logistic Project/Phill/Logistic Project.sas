data bid; 
	set al.bid_test; 
run; 

*CHECKING FOR CONFOUNDING AND INTERACTIONS; 

proc freq data=bid nlevels; 
	tables win_bid*region win_bid*sector / chisq measures plots(only) = freqplot (scale=percent twoway=stacked);
/*	tables region*win_bid*sector / all bdt plots(only)=oddsratioplot(stats);*/
	title 'Contingency Tables Analysis Assessing Winning Bids';
run; 
*ZELEN NOT WORKING???; 

proc logistic data=bid alpha=.001
	plots (only) =(oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=effect ref='Lodging') ; 
/*	BACK:	model	win_bid(event='Yes') = cost time bid_price sector region number_of_competitor_bids actual_cost competitor_a competitor_b competitor_c competitor_d competitor_e competitor_f competitor_g competitor_h competitor_i competitor_j*/
/*			/clodds=pl selection=backward slstay=.0001 ;*/
/*	STEP:	model	win_bid(event='Yes') = cost time bid_price sector region number_of_competitor_bids actual_cost competitor_a competitor_b competitor_c competitor_d competitor_e competitor_f competitor_g competitor_h competitor_i competitor_j*/
/*			/clodds=pl selection=stepwise slentry=.05 slstay=.001;*/
	FWD:	model win_bid(event='Yes') = 
			sector region est_cost est_years bid_price num_bids actual_cost competitor_a competitor_b competitor_c competitor_d competitor_e competitor_f competitor_g competitor_h competitor_i competitor_j
/*			sector|region|est_cost|est_years bid_price|num_bids actual_cost|competitor_a|competitor_b|competitor_c|competitor_d|competitor_e|competitor_f|competitor_g|competitor_h|competitor_i|competitor_j*/
			/clodds=PL selection=forward slentry=.0001 hierarchy=single include=17; 
run; 

/* proc sgplot data=bid; */
/* 	scatter x=winning_bid_price Y=bid_price; */
/* title 'Winning Bid vs AL's Bid'; */
/*proc sgplot data=bid; */
/*	scatter x=bid_price y=number_of_competitor_bids; */
/*	title 'Bid Price vs. Number of Competitors'; */
/* run; */

proc logistic data=bid alpha=.001
	plots (only) =(roc oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=effect ref='Military') ; 
	TEST:	model	win_bid(event='Yes') = cost bid_price number_of_competitor_bids region sector/clodds=pl outroc=ROC;
	ROC 	'OMIT SECTOR'				cost bid_price number_of_competitor_bids region ;
	ROC		'OMIT REGION'				cost bid_price number_of_competitor_bids  sector;
	ROC		'OMIT REGION AND SECTOR'	cost bid_price number_of_competitor_bids ;
	ROC 	'OMII # OF COMP BIDS'		cost bid_price region sector ;
	ROCCONTRAST /estimate=allparis; 
	title 'Comparing ROCs';
run; 
title; 
 *YOUDEN STAT FOR CUTOFF*; 

 data Youden; 
	set Roc;
	Spec = abs(_1mspec_-1);
	J = _sensit_+spec-1;
run; 

proc means data=youden; 
	var J; 
run; 

proc print data=youden;
	where .79<=J<=0.82;
run; 

proc freq data=bid; where competitor_a =1; table sector*region; title 'Competitor A'; 
proc freq data=bid; where competitor_b =1; table sector*region;title 'Competitor B'; 
proc freq data=bid; where competitor_c =1; table sector*region;title 'Competitor C'; 
proc freq data=bid; where competitor_d =1; table sector*region;title 'Competitor D'; 
proc freq data=bid; where competitor_e =1; table sector*region;title 'Competitor E'; 
proc freq data=bid; where competitor_f =1; table sector*region;title 'Competitor F'; 
proc freq data=bid; where competitor_g =1; table sector*region;title 'Competitor G'; 
proc freq data=bid; where competitor_h =1; table sector*region;title 'Competitor H'; 
proc freq data=bid; where competitor_i =1; table sector*region;title 'Competitor I'; 
proc freq data=bid; where competitor_j =1; table sector*region;title 'Competitor J'; 

data bid_con; 
	set bid; 
	competitor_CDG=competitor_C + Competitor_D + COmpetitor_G;
run; 

proc freq data=bid_con; 
	tables win_bid*region/ plots(only) = freqplot (scale=percent twoway=stacked); 
run; 
proc logistic data=bid_con alpha=.001
	plots (only) =(oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=reference ref='Lodging') ; 
	TEST:	model win_bid(event='Yes') = 
			sector region est_cost est_years bid_price num_bids actual_cost competitor_a competitor_b competitor_cdg  competitor_e competitor_f  competitor_h competitor_i competitor_j 
			/clodds=PL selection=stepwise slstay=.0001 slentry=.1 include=2; 
run; 
 
proc logistic data=bid_con alpha=.001
	plots (only) =(oddsratio effect(clband showobs) ROC); 
	class region(param=effect ref='Northeast') sector (param=reference ref='Lodging') ; 
/*	BACK0001:		model win_bid(event='Yes') = est_cost bid_price num_bids				/ clodds=PL;*/
	BACK_SEC_REG:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region	/ clodds=PL; 
/*	SW_SEC_REG:		model win_bid(event='Yes') = 					num_bids sector region	/ clodds=PL;*/
	ROC 'Backwards at alpha=.0001'				est_cost bid_price num_bids;
	ROC	'Stepweise including Sector and Region'	num_bids sector region;
	ROC 'Ignoring Num_Bids with Sector&Region'	est_cost bid_price sector region;
	ROCCONTRAST / estimate=allpairs; 	
run; 

data bid_val; 
	set al.bid_val; 
	competitor_CDG=competitor_C + Competitor_D + COmpetitor_G;
run; 


proc logistic data=bid_val plots(only)=(oddsratio roc effect(clband showobs));
	class region(param=effect ref='Northeast') sector (param=reference ref='Lodging') ; 
	BACK_SEC_REG:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region	/ clodds=PL; 
run; 	 
	

*BOX TIDWELL TRANSFORMATION checking Assumptions; 
data test_assumption; 
	set bid_con; 
	Est_Cost_log = Est_cost*log(cost); 
	Bid_log = bid_price*log(bid_price); 
	Est_Years_Log = Est_years*log(Est_years); 
	NumBids_log = Num_bids*log(Num_bids); 
	win_log = win_price*log(win_price); 
	actual_log = actual_cost*log(actual_cost); 
	Key_Comp_log = N_Key_comp*log(n_key_comp); 
run; 

proc logistic data=test_assumption alpha=.001
	plots (only) =(oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=reference ref='Lodging') ; 
/*	NumBids_log:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region NumBids_log	/ clodds=PL; */
/*	Est_Cost_log:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region Est_Cost_log	/ clodds=PL; */
	Bid_log:		model win_bid(event='Yes') = est_cost bid_price num_bids sector region Bid_log		/ clodds=PL; 
run; 

/*CHECKING ASSUMPTIONS IN THE CONTINUOUS VARIABLES*/

data test_assumption; 
	set bid_con; 
	Est_Cost_log = Est_cost*log(cost); 
	Bid_log = bid_price*log(bid_price); 
	Est_Years_Log = Est_years*log(Est_years); 
	NumBids_log = Num_bids*log(Num_bids); 
	win_log = win_price*log(win_price); 
	actual_log = actual_cost*log(actual_cost); 
	Key_Comp_log = N_Key_comp*log(n_key_comp); 
run; 

proc logistic data=test_assumption alpha=.001
	plots (only) =(oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=reference ref='Lodging') ; 
/*	NumBids_log:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region NumBids_log	/ clodds=PL; */
/*	Est_Cost_log:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region Est_Cost_log	/ clodds=PL; */
	Bid_log:		model win_bid(event='Yes') = est_cost bid_price num_bids sector region Bid_log		/ clodds=PL; 
run; 
