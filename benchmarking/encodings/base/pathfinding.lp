#include "../directions.lp".
#include "../grid-functions.lp".
#include "../tracks.lp".

#const h=12.

train(Z) :- start(Z,_,_,_).

% starting nodes
cell((Z,ready),ready)           :- start(Z,_,_,_).
connected((Z,ready),D,(X,Y))    :- start(Z,(X,Y),_,D).

% goal nodes
cell((Z,goal),goal)             :- end(Z,_,_).
connected((X,Y),D,(Z,goal))     :- end(Z,(X,Y),_), dir(D).

% move
ready(Z,R) :- start(Z,_,R,_).
{ move(Z,U,V,T) : connected(U,D,V)   } <= 1 :- train(Z), ready(Z,R), T=R+1..h.

drive(Z,(Z,ready),R)    :- ready(Z,R).
drive(Z,V,T)            :- move(Z,_,V,T), T=0..h.
drive(Z,U,T)            :- drive(Z,U,T-1), not drive(Z,(Z,goal),T-1), not move(Z,U,_,T), T=0..h.

poss(U,V,W) :- connected(U,D,V), connected(V,D',W), cell(V,T), transition(T,(D,D')).
poss(U,V,W) :- connected(U,D,V), connected(V,D,W),  cell(V,T), transition(T,(_,D)), start(Z,V,_,D), U = (Z,ready).
poss(U,V,W) :- connected(U,_,V), end(Z,V,_), W = (Z,goal).

% TO DO - we have illegal moves coming in
% :- move(Z,U,V,T), move(Z,V,W,T+1), not poss(U,V,W).
:- move(Z,U,V,T-1), connected(U,D,V), move(Z,V,W,T), connected(V,D',W), not transition(T,(D,D')).

:- move(Z,U,_,T), not drive(Z,U,T-1).
:- cell((Z,goal),goal)  , not drive(Z,(Z,goal),_).

% conflicts
% :- { drive(Z,(X,Y,_),T) } > 1, node((X,Y,D)), T=0..h.       % same cell different directions
% :- move(_,U,V,T), move(_,V,U,T), V>U.           % must map U,V to higher-level cells & make anon

#show drive/3.