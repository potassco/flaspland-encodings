#include "../../aux/aux.lp".
#include "../../translations/subnodes.lp".

time(Z,0  ) :- start(Z,_,_,_).
time(Z,T+1) :- time(Z,T), not end_of_path(Z,T), T<h.

end_of_path(Z,T) :- end(Z,(X,Y),_), move(Z,_,(X,Y,_),T).
:- not end_of_path(_,_).

{ move(Z,C,C',T) : edge(C,C') } = 1 :- time(Z,T), T>0.

:- start(Z,(X,Y),_,D), not move(Z,(X,Y,D),_,1).

:- move(Z,C,_,T), not move(Z,_,C,T-1), T>1.

#show.
#show path(Z,C,T-1) : move(Z,C,_,T).
#show path(Z,C,T)   : move(Z,_,C,T).
