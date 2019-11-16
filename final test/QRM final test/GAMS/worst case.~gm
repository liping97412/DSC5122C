$Title Securities portfolio - CVaR



 Set i  metals   /aluminum, copper, zinc/
     s  scenarios    /s1*s10000/;

 alias (i,j);

Scalars  target_return   target mean monthly return on metals   / 0.003/;


 Parameters  mean(i)  mean monthly return on individual metals

      / aluminum      0.0019
        copper        0.0046
        zinc          0.0040/ ;


 Table v(i,j)  variance-covariance array (squared monthly return)
                   aluminum      copper       zinc
       aluminum    0.002383      0.001933     0.001644
       copper      0.001933      0.003804     0.002368
       zinc        0.001644      0.002368     0.003854;


 Parameters ro(i)  correlation matrix between zinc and the other metals
       /aluminum      0.7925
        copper        0.8182
        zinc          1.0000/;



 Parameters a(i,s)     stockastic returns
            y1(s)      auxiliary 1
            y2(i,s)    auxiliary 2
            q(i,s)     auxiliary 3;

 y1(s) = normal(0,1);
 y2(i,s)$(ord(i) ne 1) = normal(0,1);
 q(i,s)$(ord(i) ne 1) = ro(i)*y1(s)+sqrt(1-sqr(ro(i)))*y2(i,s);



 a('zinc',s) = mean('zinc')+sqrt(v('zinc','zinc'))*y1(s);

 a(i,s)$(ord(i) ne 1) = mean(i)+sqrt(v(i,i))*q(i,s);


 Variables  x(i)       fraction of portfolio invested in asset i
            e_return   expected changes of the portfolio
            mu;

 Positive Variable x, z;


 Equations  fsum     fractions must add to 1.0
            dmean    definition of mean changes on metals
            target_eq
            tails(s) calculate the worst case return;


fsum..          sum(i, x(i)) =e=  1.0;
dmean..         e_return =e= sum(i, mean(i)*x(i));
target_eq..     e_return =g=  target_return;
tails(s)..      mu=g=-sum(i,a(i,s)*x(i));


Model portfolio  / all / ;

Solve portfolio using lp minimizing mu;

Display a, x.l, e_return.l,mu.l;
