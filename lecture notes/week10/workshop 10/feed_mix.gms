$title Feed Mix Problem
$Ontext
Adapated From Chance Constraint Feed Mix Problem  (CHANCE,SEQ=26)

$Offtext

sets f  feeds     / barley, oats, sesame, grnd-meal /
     n  nutrients / protein, fats /
     s  scenario  /s1*s100/;

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

table correlation(f,f)  correlation matrix (price per ton)
         barley        oats        sesame      grnd-meal
barley      1.00        0.93        0.9        0.92
oats        0.93        1.0         0.94       0.98
sesame      0.9         0.94        1.0        0.94
grnd-meal   0.92        0.98        0.94       1.00;


table char(*,n,f) feed characteristics (pct)
                 barley    oats     sesame    grnd-meal
mean.protein     12.0      11.9      41.8       52.1
mean.fats         2.3       5.6      11.1        1.3
variance.protein   .28       .19     20.5         .62;


parameters prot(s,f)
           price(f,s);

prot(s,f) = normal(char('mean','protein',f),sqrt(char('variance','protein',f)));

price(f,s) = normal(price_mean(f),price_SD(f));



variables  cost   total cost per ton
            x(f)   feed mix (pct);

positive variable x;

equations   cdef   costdefinition
            mc     mix constraint
            fc(n)   feed constraint ;

cdef..      cost =e= sum(f, price_mean(f)*x(f));

mc..        sum(f, x(f)) =e= 1;

fc(n)..     sum((f,s), prot(s,f)*x(f))/card(s)  =g= req(n);

models chance chance model        /all/

solve chance minimizing cost using lp;

display x.l, cost.l;
