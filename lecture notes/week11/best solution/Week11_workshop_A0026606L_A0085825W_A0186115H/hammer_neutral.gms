$Title O'Neil Hammer 3/2 wetsuit - Risk Neutral

$ontext
 options to control the random number generator, the solver and the output
$offtext

* some super big figures to prevent error (e.g. when not able to converge)
Options seed    =   12345
        limrow  =   0
        limcol  =   0
        iterlim =   1000000
        reslim  =   1000000
        sysout  =   off
        solprint =  off;


Set s  scenarios    /s1*s100/;

Scalars mean      mean demand                                  /3192/
        sd        standard deviation of demand                 /1181/
        p         price of the wetsuit                         /190/
        c         average purchase cost                        /110/
        v         salvage value                                /90/;

Parameters demand(s)  demand in scenario s;

demand(s) = max(normal(mean,sd),0);

Variables   q          number of suits ordered from supplier
            sales(s)      number of suites sold
            leftover(s)   leftover inventory
            profit(s)     profit from selling the wetsuits in scenario s
            exp_profit     expected profit from selling the wetsuits;

Positive Variable q, sales, leftover;


Equations  sales_demand(s)    sales in scenario s less than demand
           sales_orders(s)    sales in scenario s are less than orders
           leftover_eq(s)     equation to compute leftover inventory
           profit_eq(s)       profit in scenario s
           exp_profit_eq      expected profit;


sales_demand(s).. sales(s) =l= demand(s);

sales_orders(s).. sales(s) =l= q;

leftover_eq(s)..  leftover(s)=e= q -sales(s);

profit_eq(s)..    profit(s)=e=(p-c)*sales(s)-(c-v)*leftover(s);

* sum of profit over all scenarios divided by the no. of scenarios
exp_profit_eq..   exp_profit =e= sum(s, profit(s))/card(s);


Model hammer  / all / ;

Solve hammer using lp maximizing exp_profit;

*Display exp_profit.l, q.l, profit.l,sales.l, leftover.l, demand;

********************************************************************************
***** Other Measures of Performance ********************************************
********************************************************************************

Scalars exp_sales expected sales
        exp_lost_sales expected lost sales
        exp_leftover expected leftover inventory
        stockout_prob stockout probability;


exp_sales      = sum(s,sales.l(s))/card(s);

exp_lost_sales = sum(s,max(demand(s)-q.l,0))/card(s);

exp_leftover   = sum(s,leftover.l(s))/card(s);

stockout_prob  = sum(s $ (demand(s) > q.l), 1)/card(s);

*Display exp_sales, exp_lost_sales, exp_leftover, stockout_prob;


********************************************************************************
***** Display Results in Text Files ********************************************
********************************************************************************
file results /hammer_results.txt/;
put results;

put 'Orders ', @20, 'Exp_profit ', @40, 'Exp_sales ', @60, 'Exp_lost_sales ',
@80, 'Exp_leftover ', @100, 'Stockout_prob '//;

put  q.l, @20, exp_profit.l, @40, exp_sales, @60, exp_lost_sales,
@80, exp_leftover, @100, stockout_prob//;

put //;
put 'Scenario', @20, 'Profit ', @40, 'Sales ', @60, 'Leftover_inv ', @80, 'demand '/;

loop(s,put s.tl, profit.l(s), @40, sales.l(s), @60, leftover.l(s), @80, demand(s)/);


********************************************************************************
***** Display Results in Text Files ********************************************
******Using More FILES *********************************************************
********************************************************************************
$ontext
file results /hammer_results.txt/;
put results;
put 'Orders ',     @24, q.l //;
put 'Exp_profit ', @24, exp_profit.l //;
put 'Exp_sales ', @24, exp_sales //;
put 'Exp_lost_sales ', @24, exp_lost_sales //;
put 'Exp_leftover ', @24, exp_leftover //;
put 'Stockout_prob ', @24, stockout_prob //;


file profit_file /hammer_profit.txt/;
put profit_file;
loop(s,put profit.l(s)/);

file sales_file /hammer_sales.txt/;
put  sales_file;
loop(s,put sales.l(s)/);


file leftover_file /hammer_leftover.txt/;
put leftover_file;
loop(s,put leftover.l(s)/);

file demand_file /hammer_demand.txt/;
put demand_file;
loop(s,put demand(s)/);
$offtext



