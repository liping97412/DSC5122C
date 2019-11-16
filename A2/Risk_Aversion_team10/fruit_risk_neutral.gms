$title Feed Mix Problem
$Ontext
Adapated From Chance Constraint Feed Mix Problem  (CHANCE,SEQ=26)

$Offtext

sets f  fruit     / Apple, Lemon, Grape, Orange /
     n  nutrients / Calories,Protein,Fiber,Carbohydrate,Vitamin_A, Vitamin_C /
     s  scenario  /s1*s10000/;

parameter   req(n)    requirements (100g) / Calories=46.35,Protein=0.87,Fiber=3.23,Carbohydrate=11.28,Vitamin_A=5.33, Vitamin_C=34.5 /;


parameters  price_mean(f)  Mean fruit prices (price per 100g)
                                                      / Apple        0.55
                                                        Lemon        1.54
                                                        Grape        1.30
                                                        Orange       0.60 /;

parameters  price_SD(f)  SD of fruit prices (price per 100g)
                                                      / Apple        0.112
                                                        Lemon        0.764
                                                        Grape        0.396
                                                        Orange       0.053 /;

Parameters ro(f)  correlation matrix between apple and the other fruits
       /Apple        1.000
        Lemon        0.405
        Grape        0.052
        Orange       0.346/;



table correlation(f,f)  correlation matrix (price per 100g)
             Apple      Lemon      Grape    Orange
Apple        1.000      0.405      0.052     0.346
Lemon        0.405      1.000     -0.084     0.492
Grape        0.052     -0.084      1.000    -0.383
Orange       0.346      0.492     -0.383     1.000;


table char(*,n,f) fruit characteristics (pct)
                         Apple     Lemon      Grape     Orange
mean.Calories            54.39     20.00     70.24     40.75
mean.Protein              0.30      1.20      0.97      1.00
mean.Fiber                2.27      4.70      3.43      2.50
mean.Carbohydrate        11.90     10.70     14.90      7.63
mean.Vitamin_A            1.67      2.00      5.67     12.00
mean.Vitamin_C            5.33     77.00      4.00     51.67
variance.Calories         3.63      0.00      4.79      2.85
variance.Protein          0.00      0.00      0.17      0.08
variance.Fiber            0.05      0.00      0.09      0.22
variance.Carbohydrate     0.88      0.00      1.00      0.52
variance.Vitamin_A        0.47      0.00      4.03      1.63
variance.Vitamin_C        0.47      0.00      2.94      5.79;


parameters cal(s,f)
           prot(s,f)
           fiber(s,f)
           carbo(s,f)
           va(s,f)
           vc(s,f)
           price(f,s);

cal(s,f) = normal(char('mean','Calories',f),sqrt(char('variance','Calories',f)));
prot(s,f) = normal(char('mean','Protein',f),sqrt(char('variance','Protein',f)));
fiber(s,f) = normal(char('mean','Fiber',f),sqrt(char('variance','Fiber',f)));
carbo(s,f) = normal(char('mean','Carbohydrate',f),sqrt(char('variance','Carbohydrate',f)));
va(s,f) = normal(char('mean','Vitamin_A',f),sqrt(char('variance','Vitamin_A',f)));
vc(s,f) = normal(char('mean','Vitamin_C',f),sqrt(char('variance','Vitamin_C',f)));

price(f,s) = normal(price_mean(f),price_SD(f));

Parameters a(f,s)  stockastic returns
           y1(s)   auxiliary 1
           y2(f,s)   auxiliary 2
           q(f,s)   auxiliary 3;

y1(s) = normal(0,1);
y2(f,s)$(ord(f) ne 1) = normal(0,1);
q(f,s)$(ord(f) ne 1) = ro(f)*y1(s)+sqrt(1-sqr(ro(f)))*y2(f,s);



a('Apple',s) = price_mean('Apple')+sqrt(correlation('Apple','Apple'))*y1(s);

a(f,s)$(ord(f) ne 1) = price_mean(f)+sqrt(correlation(f,f))*q(f,s);



variables  cost   total cost per 100g
            x(f)  fruit mix per 100g;

positive variable x;

equations   cdef     costdefinition
            mc       mix constraint
            calc     calories constraint
            protc    protein constraint
            fiberc   fiber constraint
            carboc   Carbohydrate constraint
            vac      Vitamin_A constraint
            vcc      Vitamin_C constraint;

cdef..      cost =e= sum(f, price_mean(f)*x(f));

mc..        sum(f, x(f)) =e= 1;

calc..    sum((f,s), cal(s,f)*x(f))/card(s)  =g= req('Calories');
protc..   sum((f,s), prot(s,f)*x(f))/card(s)  =g= req('Protein');
fiberc..  sum((f,s), fiber(s,f)*x(f))/card(s)  =g= req('Fiber');
carboc..  sum((f,s), carbo(s,f)*x(f))/card(s)  =g= req('Carbohydrate');
vac..     sum((f,s), va(s,f)*x(f))/card(s)  =g= req('Vitamin_A');
vcc..     sum((f,s), vc(s,f)*x(f))/card(s)  =g= req('Vitamin_C');


models chance chance model        /all/

solve chance minimizing cost using lp;

display a, x.l, cost.l;
