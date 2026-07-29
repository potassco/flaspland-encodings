#include "../aux/aux.lp".
#include "../translations/edge-functions.lp".

time(Z,0  ) :- start(Z,_,_,_).
time(Z,T+1) :- time(Z,T), not end_of_path(Z,T), T<h.

end_of_path(Z,T) :- end(Z,C,_), move(Z,_,C,T).
:- not end_of_path(_,_).

{ move(Z,C,C',1) : edge(C,C'), connected(C,D,C') } = 1 :- start(Z,C,_,D).
{ move(Z,C,C',T) : edge(C,C')                    } = 1 :- time(Z,T), T>1.

:- move(Z,C,_,T), not move(Z,_,C,T-1), T>1.

:- move(Z,C,C',T), move(Z,C',C'',T+1), d(C,C',D), not p(C',C'',D).

#show.
#show path(Z,C,T-1) : move(Z,C,_,T).
#show path(Z,C,T  ) : move(Z,_,C,T).
