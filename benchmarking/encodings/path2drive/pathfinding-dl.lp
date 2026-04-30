
{ resolve((Z,T),(Z',T')) ;
  resolve((Z',T'),(Z,T)) } = 1 :- path(Z,C,T), path(Z',C,T'), Z < Z'.

#const edge=0.

% either #edge with clingo
#edge ((Z,T-1),( Z, T)) : train(Z), T=1..h,       edge = 1.
#edge ((Z,T+1),(Z',T')) : resolve((Z,T),(Z',T')), edge = 1.

% or &diff with clingo-dl
&diff{ (Z,T-1) + 1 } <= ( Z, T) :- train(Z), T=1..h,       edge != 1.
&diff{ (Z,T+1) + 0 } <= (Z',T') :- resolve((Z,T),(Z',T')), edge != 1.
&diff{   0 - (Z,0) } <= -D      :- start(Z,_,D,_),         edge != 1.
%
:- resolve((Z,T),(Z',T')), Z < Z', % (Z,T+1) <= (Z',T')
   resolve((Z',T'-1),(Z,T+1)),     % (Z',T') <= (Z,T+1)
   edge != 1.                      % (Z,T+1)  = (Z',T')   
                                   
