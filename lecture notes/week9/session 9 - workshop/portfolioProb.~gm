$Title Secutities portfolio



 Set i  commodities   /aapl, mcd, qqq, spy, tlt/;

 alias (i,j);

 Scalars  target_return    target mean annual return on portfolio   / 0.02/;

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

 Variables  x(i)       fraction of portfolio invested in asset i
            variance   variance of portfolio
            e_return   expected return of the portfolio
            var        value at risk;

 Positive Variable x;

 Equations  fsum    fractions must add to 1.0
            dmean   definition of mean return on portfolio
            target_eq  expected value is at least equal to the target return
            dvar    definition of variance
            chance  chance constraint with target for minimum return;

fsum..        sum(i, x(i))=e=  1.0  ;
dmean..       e_return =e= sum(i, mean(i)*x(i));
target_eq..   e_return =g=  target_return;
dvar..        variance =e= sum((i,j), x(i)*v(i,j)*x(j));
chance..      var-e_return+1.64*sqrt(variance)  =l= 0;



Model portfolio  / all / ;

Solve portfolio using nlp minimizing variance;

Display x.l, e_return.l, variance.l, var.l;
