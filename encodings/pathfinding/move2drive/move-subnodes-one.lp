#include "../directions.lp".
#include "../tracks.lp".
#include "../grid-functions.lp".

#include "../train-time.lp".
#include "../subnodes.lp".

#include "move-collisions-subnodes-one.lp".

{ move(Z,C,C',T) : edge(C,C') } <= 1 :- time(Z,T), not ready(Z,T).

drive(Z,(X,Y,D), T) :- start(Z,(X,Y),_,D), ready(Z,T).
drive(Z,C',      T) :- move(Z,C,C',T), time(Z,T).
drive(Z,C,       T) :- drive(Z,C,T-1), not move(Z,C,_,T), time(Z,T).

:- move(Z,C,_,T), not drive(Z,C,T-1).

arrive(Z,T) :- end(Z,(X,Y),_), move(Z,_,(X,Y,_),T).
:- not arrive(Z,_), start(Z,_,_,_).

% #show drive/3.
#show.
#show drive(Z,(X,Y),T) : drive(Z,(X,Y,_),T).
