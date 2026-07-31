#include "../../aux/aux.lp".
#include "../../translations/subnodes.lp".

{ move(Z,(X,Y,D),C',1  ) : edge((X,Y,D),C') } = 1 :- start(Z,(X,Y),_,D).
{ move(Z,(X,Y,D),C',T+1) : edge((X,Y,D),C') } = 1 :- move(Z,_,(X,Y,D),T), not end(Z,(X,Y),_), T<h.

end_of_path(Z,T) :- end(Z,(X,Y),_), move(Z,_,(X,Y,_),T).
:- not end_of_path(_,_).

#show.
#show path(Z,C,T-1) : move(Z,C,_,T).
#show path(Z,C,T)   : move(Z,_,C,T).
