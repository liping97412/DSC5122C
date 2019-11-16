$Title Project Management - CVaR

$ontext
 options to control the random number generator, the solver and the output
$offtext

options seed    =   12345
        limrow  =   0
        limcol  =   0
        iterlim =   1000000
        reslim  =   1000000
        sysout  =   off
        solprint =  off;



set s  scenarios    /s1*s1000/
    j  activities   /a*j/;


$ontext
Random number generation from the PERT- beta distribution.


Algorithm:
1. Calculate the pert_alpha and pert_beta for activity j

2. generate u from U(0,1)

3. solve F(w) = u where F(w) is the
cdf of the beta distribution.

Note: the cdf of the beta distribution with parameters pert_alpha, pert_beta is:
F(w) = betareg(w,pert_alpha,pert_beta)

For u=0 or u=1 the problem is difficult. You may want to
replace step 1 by: generate u from U(0.001,0.999).
$offtext


parameters  a(j)     minimum value for activity j time /a   2
                                                        b   5
                                                        c   10
                                                        d   4
                                                        e   7
                                                        f   10
                                                        g   1
                                                        h   1
                                                        i   1
                                                        j   2/;

parameters  m(j)     most likely activity j time       /a   5
                                                        b   7
                                                        c   12
                                                        d   5
                                                        e   12
                                                        f   15
                                                        g   3
                                                        h   5
                                                        i   2
                                                        j   3/;


parameters  b(j)     most likely activity j time       /a   7
                                                        b   11
                                                        c   18
                                                        d   8
                                                        e   15
                                                        f   21
                                                        g   5
                                                        h   6
                                                        i   3
                                                        j   4/;


parameters  pert_alpha(j) alpha parameter for the Pert Distribution of activity j
            pert_beta(j)  beta parameter for the Pert Distribution of activity j
            d(j,s) j activity time in scenario s;

pert_alpha(j) =((2*(b(j)+4*m(j)-5*a(j)))/(3*(b(j)-a(j))))*(1+4*(((m(j)-a(j))*(b(j)-m(j)))/((b(j)-a(j))**2)));

pert_beta(j) =((2*(5*b(j)-4*m(j)-a(j)))/(3*(b(j)-a(j))))*(1+4*(((m(j)-a(j))*(b(j)-m(j)))/((b(j)-a(j))**2)));

display pert_alpha, pert_beta;


parameters   u(j,s) random number from uniform dist. for activity j in scenario s;

u(j,s) = uniform(1.0e-6,1-1.0e-6);

variable w(j,s)   regularized activity time for activity j in scenario s;

equation pert(j,s)     regularized pert-beta distribution probability;

pert(j,s).. betareg(w(j,s),pert_alpha(j),pert_beta(j)) =e= u(j,s);

** from 0 to 1
model pert_regularized /pert/;
** w.low near 0
w.lo(j,s) = 1.0e-6;
** initial value = 0.5
w.l(j,s) = 0.5;
** w.high near 1
w.up(j,s) = 1-1.0e-6;

**Solve a system of non-linear equations
solve pert_regularized using cns;

d(j,s) = a(j)+(b(j)-a(j))*w.l(j,s);

**get the maximum and minimum values for the activity times
parameters min_d(j)   minimum d for activity j in scenario s
           max_d(j)   maximum d for activity j in scenario s;

** smin -> get min in all scenarios
min_d(j) = smin(s,d(j,s));
max_d(j) = smax(s,d(j,s));


display min_d, max_d;
display w.l,d;

********************************************************************************
********************************************************************************
*********Solving the PERT model using CV@R**************************************
********************************************************************************
********************************************************************************

** i and j are both accepted as indices for the activities
alias (j,i);

scalar beta  prob of not being in the tail   /0.9/;

**Each activity is a not predecessor of itself
table c(i,j) activity i is a predecessor of j
** a is a predecessor of c
   b  c  d  e  f  g  h  i  j
a  1  0  0  0  0  0  0  0  0
b  0  0  1  1  0  0  0  0  0
c  0  0  1  1  0  1  0  0  0
d  0  0  0  0  0  0  0  1  0
e  0  0  0  0  1  0  0  0  0
f  0  0  0  0  0  0  0  0  1
g  0  0  0  0  0  0  1  0  0
h  0  0  0  0  0  0  0  1  0
i  0  0  0  0  0  0  0  0  1;

**display c;


variables   y(s)          finishing time in scenario s
            x(j,s)        finishing time of activity j in scenario s
            var           value at risk
            cvar          conditional value at risk
            z(s)          tail profit in scenario s
            mu            ;

positive Variable y, x, z;


equations  activity(i,j,s)  interdependence between activity times
           finishing(j,s)   control for the longest finishing time
           tails(s) calculate the value of the tail
           cvar_eq objective function
           worstcase(s)    ;

** $ means condition
activity(i,j,s)..  x(j,s) =g= d(j,s)+x(i,s)$(c(i,j) = 1);

worstcase(s)..       mu =g= y(s);

finishing(j,s)..  y(s)=g=x(j,s);

tails(s)..        z(s)=g= y(s)-var;

cvar_eq..         cvar =e= var+1/((1-beta)*card(s))*sum(s,z(s));

Model project  /activity, worstcase, finishing, tails, cvar_eq / ;

Solve project using lp minimizing mu;

Display mu.l, var.l, cvar.l,z.l, x.l;


********************************************************************************
***** Display Results in Text Files ********************************************
********************************************************************************
file results /project_results.txt/;
put results;

put 'CVaR ', @20, 'VaR '//;
put  cvar.l, @20, var.l//;

put //;
put 'Scenario', @20, 'Finish_time ', @40, 'Tail '//;
loop(s,put s.tl, y.l(s), @40, z.l(s)/);

put //;
put 'Scenario', @20,'Activity ', @40, 'Activity_Finish_time '//;
loop((s,j),put s.tl, @20, j.tl, @40, x.l(j,s)/);


