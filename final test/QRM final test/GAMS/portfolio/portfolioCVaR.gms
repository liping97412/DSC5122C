$Title Securities portfolio - CVaR



 Set i  commodities   /spy, aapl, mcd, qqq, tlt/
     s  scenarios    /s1*s10000/;

 alias (i,j);


Scalar beta      prob. of not being in the tail               /0.9999/;


 Parameters  mean(i)  mean monthly returns on individual securities

      / aapl      0.0294
        mcd       0.0132
        qqq       0.0217
        spy       0.0123
        tlt       -0.001/ ;


 Table v(i,j)  variance-covariance array (squared monthly return)
               aapl        mcd          qqq        spy          tlt
       aapl    0.00237    0.00017      0.00007    0.00025     0.00028
       mcd     0.00017    0.00135      0.00024   -0.00024     0.00012
       qqq     0.00007    0.00024      0.00080   -0.00006     0.00006
       spy     0.00025   -0.00024     -0.00006    0.00036     0.00005
       tlt     0.00028    0.00012      0.00006    0.00005     0.00222;


 Parameters ro(i)  correlation matrix betwee spy and the other securities
       /aapl     0.270
       mcd     -0.337
       qqq     -0.123
       spy      1.000
       tlt      0.090/;



 Parameters a(i,s)  stockastic returns
            y1(s)   auxiliary 1
            y2(i,s)   auxiliary 2
            q(i,s)   auxiliary 3;

 y1(s) = normal(0,1);
 y2(i,s)$(ord(i) ne 1) = normal(0,1);
 q(i,s)$(ord(i) ne 1) = ro(i)*y1(s)+sqrt(1-sqr(ro(i)))*y2(i,s);



 a('spy',s) = mean('spy')+sqrt(v('spy','spy'))*y1(s);

 a(i,s)$(ord(i) ne 1) = mean(i)+sqrt(v(i,i))*q(i,s);


 Variables  x(i)       fraction of portfolio invested in asset i
            e_return   expected return of the portfolio
            var        value at Risk
            cvar       conditional value at risk
            z(s)       tail profit in scenario s;

 Positive Variable x, z;


 Equations  fsum    fractions must add to 1.0
            dmean   definition of mean return on portfolio
            tails(s) calculate the value of the tail
            cvar_eq objective function ;


fsum..          sum(i, x(i))=e=  1.0  ;
dmean..         e_return =e= sum(i, mean(i)*x(i));
tails(s)..      z(s)=g=-sum(i,a(i,s)*x(i))-var;
cvar_eq..       cvar =e= var+1/((1-beta)*card(s))*sum(s,z(s));


Model portfolio  / all / ;

Solve portfolio using lp minimizing cvar;

Display a, x.l, e_return.l,var.l, cvar.l;
