$Title Petroleum Speculator

$Ontext

   This is a linear programming formulation for optimal management of petroleum
   stockpiles by a speculator.

$Offtext


Sets  s    state of inventory /s0*s10/
      i    state of the oil market  / normal, disrupted, very_disrupted/

Alias(s,sp,spp), (i,j);



Scalars  b     discount factor  pr month                        /.995/
         h     holding cost (us$ per month)                     /0.02/
         lag   policy lag  (allowed discrete inventory jumps)   /2/;

Table  pr(i,j)  transition probability of the world oil market per month
                normal  disrupted very_disrupted
normal            .9       .1           0.0
disrupted         .4       .5           0.1
very_disrupted    .0       .2           0.8;


Parameters  lev(s)      level of the inventory  (Kbbl)
            price(i)  oil price (us$ per bbl)        /normal  40, disrupted  75, very_disrupted 125/
            decision_profit(s,i,sp)  profit associated with each action in a given state;


lev(s)    = 100*(ord(s)-1);


decision_profit(s,i,sp) = inf;
decision_profit(s,i,sp)$(abs(ord(sp)-ord(s)) le lag) = price(i)*(lev(s)-lev(sp))-h*lev(sp);



Display lev, price, decision_profit;

Variables  v(s,i) present value of the profit in state (si)
           z      present value of expected cost;

Equations  stateValue(s,i,sp) define the main equation to calculate the state value
           profit             profit definition;


stateValue(s,i,sp)$(abs(ord(sp)-ord(s))le lag)..v(s,i)-b*sum(j,pr(i,j)*v(sp,j))=g=decision_profit(s,i,sp);

profit..   z =e= sum((s,i),v(s,i));

Model strategic / all /;
Solve strategic using lp minimizing z;


Parameters td(s,i,sp) trade ie the Kbbl bought or sold in state (si);

td(s,i,sp) = 1$ (stateValue.m(s,i,sp)>0);

Display  decision_profit, z.l, v.l, td, stateValue.m;
