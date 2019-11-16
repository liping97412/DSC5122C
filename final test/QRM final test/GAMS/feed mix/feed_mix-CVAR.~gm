$title Feed Mix Problem
$Ontext
CVAR

$Offtext

sets f  feeds     / barley, oats, sesame, grnd-meal /
     n  nutrients / protein, fats /
     s  scenario  /s1*s10000/;

Scalar beta      prob. of not being in the tail  /0.9999/;

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

parameter   req(n)    requirements (pct)
                                         /
                                         protein = 21
                                         fats = 5
                                         /;

parameters  price_mean(f)  Mean feed prices (price per ton)
                                                      /
                                                      barley    24.55
                                                      oats      26.75
                                                      sesame    39.00
                                                      grnd-meal 40.50
                                                      /;

parameters  price_SD(f)  SD of feed prices (price per ton)
                                                      /
                                                      barley    15.3
                                                      oats      13.18
                                                      sesame    18.10
                                                      grnd-meal 19.7
                                                      /;

parameters ro(f)  correlation matrix between barley and the other
                                                      /
                                                      barley      1.00
                                                      oats        0.3
                                                      sesame      0.4
                                                      grnd-meal   0.5
                                                      /;

parameters
             price(f,s) stochastic price
             y1(s)   auxiliary 1
             y2(f,s)   auxiliary 2
             q(f,s)   auxiliary 3
             prot(s,f)
             price(f,s);

 prot(s,f) = normal(char('mean','protein',f),sqrt(char('variance','protein',f)));
 y1(s) = normal(0,1);
 y2(f,s)$(ord(f) ne 1) = normal(0,1);
 q(f,s)$(ord(f) ne 1) = ro(f)*y1(s)+sqrt(1-sqr(ro(f)))*y2(f,s);
 price('barley',s) = price_mean('barley')+ price_SD('barley')*y1(s);
 price(f,s)$(ord(f) ne 1) = price_mean(f)+ price_SD(f) * q(f,s);

variables   cost   total cost per ton
            x(f)   feed mix (pct)
            var        value at Risk
            cvar       conditional value at risk
            z(s)       tail profit in scenario s;

positive variable x, z;

equations   cdef   costdefinition
            mc     mix constraint
            fc(n)   feed constraint
            tails(s) calculate the value of the tail
            cvar_eq objective function ;;

cdef..      cost =e= sum(f, price_mean(f)*x(f));
mc..        sum(f, x(f)) =e= 1;
fc(n)..     sum((f,s), prot(s,f)*x(f))/card(s)  =g= req(n);
tails(s)..  z(s)=g=sum(f,price(f,s)*x(f))-var;
cvar_eq..   cvar =e= var+1/((1-beta)*card(s))*sum(s,z(s));


models cvar_feed chance model        /all/

Solve cvar_feed using lp minimizing cvar;
Display price, x.l, var.l, cvar.l, cost.l;


