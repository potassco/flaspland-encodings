#include "encodings/directions.lp".
#include "encodings/grid-functions.lp".
#include "encodings/tracks.lp".

#include "encodings/edge-functions.lp".
#include "encodings/example.lp".
% #include "envs/benchmarks/Test_00/Level_0.lp".

#const h=22.
train(Z) :- start(Z,_,_,_).

% dummy ready nodes
node((Z,ready))         :- start(Z,_,_,_).
d((Z,ready),(X,Y),D)    :- start(Z,(X,Y),_,D).
edge((Z,start),(X,Y))   :- start(Z,(X,Y),_,D).

% dummy goal nodes
node((Z,goal))          :- end(Z,_,_).
edge((X,Y),(Z,goal))    :- end(Z,(X,Y),_), node((X,Y,D)).
p((X,Y),(Z,goal),D)     :- end(Z,(X,Y),_), d(_,(X,Y),D).

% move
ready(Z,R) :- start(Z,_,R,_).
{ move(Z,U,V,T) : edge(U,V) } <= 1 :- train(Z), ready(Z,R), T=R+1..h.

drive(Z,(Z,ready),R)    :- ready(Z,R).
drive(Z,V,T)            :- move(Z,_,V,T), T=0..h.
drive(Z,U,T)            :- drive(Z,U,T-1), not drive(Z,(Z,goal),T-1), not move(Z,U,_,T), T=0..h.

:- move(Z,U,_,T), not drive(Z,U,T-1).
:- node((Z,goal)), not drive(Z,(Z,goal),_).

% conflicts
% :- { drive(Z,(X,Y,_),T) } > 1, node((X,Y,D)), T=0..h.       % same cell different directions
% :- move(_,U,V,T), move(_,V,U,T), V>U.           % must map U,V to higher-level cells & make anon

% #minimize{T@1 : drive(_,_,T)}.
#show drive/3.
