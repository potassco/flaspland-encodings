#include "../../aux/aux.lp".
#include "../../translations/hypergraph.lp".

{ move(Z,C,C',C'',0  ) : hyperedge(C,C',C''), connected(C',D,C'') } = 1 :- start(Z,C',_,D).
{ move(Z,C,C',C'',T+1) : hyperedge(C,C',C'')                      } = 1 :- move(Z,_,C,C',T), not end(Z,C,_), T<h.

end_of_path(Z,T) :- end(Z,C,_), move(Z,_,C,_,T).
:- not end_of_path(_,_).

% #show move/5.
#show.
#show path(Z,C,T) : move(Z,_,C,_,T).
