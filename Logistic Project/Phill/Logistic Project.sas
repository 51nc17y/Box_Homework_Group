*CHECKING FOR CONFOUNDING AND INTERACTIONS; 
proc freq data=bid nlevels; 
	tables win_bid*region win_bid*sector / chisq measures plots(only) = freqplot (scale=percent twoway=stacked);
	tables region*win_bid*sector / all bdt plots(only)=oddsratioplot(stats);
	exact zelen; 
	title 'Contingency Tables Analysis Assessing Winning Bids';
run; 
*ZELEN NOT WORKING???; 


proc logistic data=bid alpha=.001
	plots (only) =(oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=effect ref='Military') ; 
/*	BACK:	model	win_bid(event='Yes') = cost time bid_price sector region number_of_competitor_bids actual_cost competitor_a competitor_b competitor_c competitor_d competitor_e competitor_f competitor_g competitor_h competitor_i competitor_j*/
/*			/clodds=pl selection=backward slstay=.0001 ;*/
/*	STEP:	model	win_bid(event='Yes') = cost time bid_price sector region number_of_competitor_bids actual_cost competitor_a competitor_b competitor_c competitor_d competitor_e competitor_f competitor_g competitor_h competitor_i competitor_j*/
/*			/clodds=pl selection=stepwise slentry=.05 slstay=.001;*/
	FWD:	model win_bid(event='Yes') = sector region est_cost est_years bid_price num_bids actual_cost competitor_a competitor_b competitor_c competitor_d competitor_e competitor_f competitor_g competitor_h competitor_i competitor_j
			/clodds=PL selection=forward slentry=.0001 hierarchy=single include=2; 
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

*BOX TIDWELL TRANSFORMATION; 
data test_assumption; 
	set bid; 
	Cost_log = cost*log(cost); 
	Bid_log = bid_price*log(bid_price); 
	time_log = time*log(time); 
	CompBids_log = Number_of_Competitor_bids*log(Number_of_Competitor_bids); 
	win_log = winning_bid_price*log(winning_bid_price); 
	actual_log = actual_cost*log(actual_cost); 
	Key_Comp_log = N_Key_comp*log(n_key_comp); 
run; 
