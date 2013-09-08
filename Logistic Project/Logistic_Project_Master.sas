data bid; 
	set al.bid_test; 
run; 

/*Fixing Quasi-complete Separation Issues and extreme Odds Ratios*/
data bid_con; 
	set bid; 
	competitor_CDG=competitor_C + Competitor_D + COmpetitor_G;
run; 

/*Checking for interactions (result=no interactions)*/
proc logistic data=bid_con alpha=.001
	plots (only) =(oddsratio effect(clband showobs)); 
	class region(param=effect ref='Northeast') sector (param=reference ref='Lodging') ; 
	TESTFWD:model win_bid(event='Yes') = 
			sector region est_cost est_years bid_price num_bids actual_cost competitor_a competitor_b competitor_cdg  competitor_e competitor_f  competitor_h competitor_i competitor_j 
			sector|region|est_cost|est_years bid_price|num_bids actual_cost|competitor_a|competitor_b|competitor_cdg|competitor_e|competitor_f|competitor_h|competitor_i|competitor_j
			/clodds=PL selection=forward slentry=.001 include=15; 
/*	TESTBCK:model win_bid(event='Yes') = */
/*			sector region est_cost est_years bid_price num_bids actual_cost competitor_a competitor_b competitor_cdg  competitor_e competitor_f  competitor_h competitor_i competitor_j */
/*			sector|region|est_cost|est_years bid_price|num_bids actual_cost|competitor_a|competitor_b|competitor_cdg|competitor_e|competitor_f|competitor_h|competitor_i|competitor_j*/
/*			/clodds=PL selection=backwards slstay =.001; */
run; 

/*Checking linearity assumption - Box Tidwell Transformation*/
data test_assumption; 
	set bid_con; 
	Est_Cost_log = Est_cost*log(est_cost); 
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
	NumBids_log:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region NumBids_log	/ clodds=PL; 
/*	Est_Cost_log:	model win_bid(event='Yes') = est_cost bid_price num_bids sector region Est_Cost_log	/ clodds=PL; */
/*	Bid_log:		model win_bid(event='Yes') = est_cost bid_price num_bids sector region Bid_log		/ clodds=PL; */
run; 


