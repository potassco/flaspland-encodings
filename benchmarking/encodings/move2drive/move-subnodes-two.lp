#include "../directions.lp".
#include "../tracks.lp".
#include "../grid-functions.lp".

#include "../train-time.lp".
#include "../subnodes.lp".

#include "move-collisions-subnodes.lp".

{ move(Z,C,C',T) : edge(C,C'); move(Z,C,C,T) : node(C) } = 1 :- time(Z,T), not ready(Z,T).

:- not move(Z,(X,Y,D),_,T), start(Z,(X,Y),_,D), ready(Z,T-1).
:- move(Z,C,_,T), not move(Z,_,C,T-1), time(Z,T), not ready(Z,T-1).

arrive(Z,T) :- end(Z,(X,Y),_), move(Z,_,(X,Y,_),T).
:- not arrive(Z,_), start(Z,_,_,_).

#show.
% #show drive(Z,C,T-1) : move(Z,C,_,T).
% #show drive(Z,C,T)   : move(Z,_,C,T).
#show drive(Z,(X,Y),T-1) : move(Z,(X,Y,_),_,T).
#show drive(Z,(X,Y),T)   : move(Z,_,(X,Y,_),T).
