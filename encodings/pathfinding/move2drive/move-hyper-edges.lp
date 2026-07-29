#include "../directions.lp".
#include "../tracks.lp".
#include "../grid-functions.lp".

#include "../train-time.lp".
#include "../hypergraph.lp".

#include "move-collisions-one.lp".

edge(C,C') :- hyperedge(_,C,C').
edge(C,C') :- hyperedge(C,C',_).

{ move(Z,C,C',T) : edge(C,C') } <= 1 :- time(Z,T), not ready(Z,T).

drive(Z,C, T,0   ) :- start(Z,C,_,_), ready(Z,T).
drive(Z,C',T,T'+1) :- drive(Z,C,T-1,T'),     move(Z,C,C',T), time(Z,T).
drive(Z,C, T,T'  ) :- drive(Z,C,T-1,T'), not move(Z,C,_ ,T), time(Z,T).

depart(Z,D,T) :- T = #min { T' : move(Z,C,_,T') }, start(Z,C,_,D), time(Z,T).

:- move(Z,C,_,T), not drive(Z,C,T-1,_).
:- move(Z,C,C',T), depart(Z,D,T), not connected(C,D,C').

arrive(Z,T) :- end(Z,C,_), move(Z,_,C,T).
:- not arrive(Z,_), start(Z,_,_,_).

:-                   drive(Z,C',_,0), drive(Z,C'',_,  1), not hyperedge(_,C',C'').
:- drive(Z,C,_,T-1), drive(Z,C',_,T), drive(Z,C'',_,T+1), not hyperedge(C,C',C'').
:- drive(Z,C,_,T-1), drive(Z,C',_,T), not drive(Z,_,_,T+1), not hyperedge(C,C',_).

#show.
#show drive(Z,C,T) : drive(Z,C,T,_).
