#include "../../aux/aux.lp".
#include "../../translations/hypergraph.lp".

time(Z,0) :- start(Z,_,_,_).
time(Z,T+1) :- time(Z,T), not end_of_path(Z,T), T<h.

end_of_path(Z,T) :- end(Z,C,_), move(Z,_,C,_,T).
:- not end_of_path(_,_).

{ move(Z,C,C',C'',0) : hyperedge(C,C',C''), connected(C,D,C') } = 1 :- start(Z,C,_,D).
{ move(Z,C,C',C'',T) : hyperedge(C,C',C'')                    } = 1 :- time(Z,T), T>0.

:- move(Z,C,C',_,T), not move(Z,_,C,C',T-1), time(Z,T-1).
:- move(Z,_,C,C',T), not move(Z,C,C',_,T+1), time(Z,T+1).

% #show move/5.
#show.
#show path(Z,C,T) : move(Z,_,C,_,T).
