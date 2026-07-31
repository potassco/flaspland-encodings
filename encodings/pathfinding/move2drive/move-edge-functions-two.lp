#include "../../aux/aux.lp".
#include "../../wip/train-time.lp". % file missing
#include "../../translations/edge-functions.lp".
#include "move-collisions.lp".

{ move(Z,C,C',T) : edge(C,C'); move(Z,C,C,T) : node(C) } = 1 :- time(Z,T), not ready(Z,T).

depart(Z,D,T) :- T = #min { T' : move(Z,C,C',T'), edge(C,C') }, start(Z,C,_,D), time(Z,T).

:- not move(Z,C,_ ,T), start(Z,C,_,_), ready(Z,T-1).
:- move(Z,C,C',T), depart(Z,D,T), not connected(C,D,C').
:- move(Z,C,_ ,T), not move(Z,_,C,T-1), time(Z,T), not ready(Z,T-1).

arrive(Z,T) :- end(Z,C,_), move(Z,_,C,T).
:- not arrive(Z,_), start(Z,_,_,_).

wait(Z,T,T') :- move(Z,C,C',T), edge(C,C'), T' = #min { S : move(Z,C',C'',S), edge(C',C''), S>T }, time(Z,T'), not arrive(Z,T).

:- move(Z,C,C',T), move(Z,C',C'',T'), d(C,C',D), not p(C',C'',D), wait(Z,T,T').

#show.
#show drive(Z,C,T-1) : move(Z,C,_,T).
#show drive(Z,C,T  ) : move(Z,_,C,T).
