$title Feed Mix Problem
$Ontext
Adapated From Chance Constraint Feed Mix Problem  (CHANCE,SEQ=26)

$Offtext

sets f  feeds     / barley, oats, sesame, grnd-meal /
     n  nutrients / protein, fats /
     s  scenario  /s1*s100/;

Scalar beta      prob. of not being in the tail               /0.9/;

parameter   req(n)    requirements (pct) / protein = 21, fats = 5 /;


parameters  price_mean(f)  Mean feed prices (price per ton)
                                                      / barley    24.55
                                                        oats      26.75
                                                        sesame    39.00
                                                        grnd-meal 40.50 /;

parameters  price_SD(f)  SD of feed prices (price per ton)
                                                      / barley    15.3
                                                        oats      13.18
                                                        sesame    18.10
                                                        grnd-meal 19.7/;

Parameters ro(f)  correlation matrix betwee barley and the other grain
       /barley    1
        oats      0.53
        sesame    0.50
        grnd-meal 0.22/;


table correlation(f,f)  correlation matrix (price per ton)
         barley        oats        sesame      grnd-meal
barley      1.00        0.53        0.50        0.22
oats        0.53        1.0         0.20        0.20
sesame      0.50        0.20        1.0         0.20
grnd-meal   0.22        0.20        0.20        1.00;


table char(*,n,f) feed characteristics (pct)
                 barley    oats     sesame    grnd-meal
mean.protein     12.0      11.9      41.8       52.1
mean.fats         2.3       5.6      11.1        1.3
variance.protein   .28       .19     20.5         .62;


parameters prot(s,f)
           price(f,s);

prot(s,f) = normal(char('mean','protein',f),sqrt(char('variance','protein',f)));


Parameters a(f,s)  stockastic returns
           y1(s)   auxiliary 1
           y2(f,s)   auxiliary 2
           q(f,s)   auxiliary 3;

y1(s) = normal(0,1);
y2(f,s)$(ord(f) ne 1) = normal(0,1);
q(f,s)$(ord(f) ne 1) = ro(f)*y1(s)+sqrt(1-sqr(ro(f)))*y2(f,s);



a('barley',s) = price_mean('barley')+sqrt(correlation('barley','barley'))*y1(s);

a(f,s)$(ord(f) ne 1) = price_mean(f)+sqrt(correlation(f,f))*q(f,s);



variables  cost   total cost per ton
           x(f)   feed mix (pct)
           var        value at Risk
           cvar       conditional value at risk
           z(s)       tail profit in scenario s;

Positive Variable x, z;

equations   cdef   costdefinition
            mc     mix constraint
            fc(n)   feed constraint
            tails(s) calculate the value of the tail
            cvar_eq objective function ;

cdef..      cost =e= sum(f, price_mean(f)*x(f));

mc..        sum(f, x(f)) =e= 1;

fc(n)..     sum((f,s), prot(s,f)*x(f))/card(s)  =g= req(n);

tails(s)..      z(s)=g=-sum(f,a(f,s)*x(f))-var;

cvar_eq..       cvar =e= var+1/((1-beta)*card(s))*sum(s,z(s));

models chance chance model        /all/

solve chance minimizing cost using lp;

display a, x.l, var.l, cvar.l;
