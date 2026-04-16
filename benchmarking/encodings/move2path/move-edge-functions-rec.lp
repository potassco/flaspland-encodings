#include "../directions.lp".
#include "../tracks.lp".
#include "../grid-functions.lp".

#include "../edge-functions.lp".

{ move(Z,C,C',1  ) : edge(C,C'), connected(C,D,C') } = 1 :- start(Z,C,_,D).
{ move(Z,C,C',T+1) : edge(C,C')                    } = 1 :- move(Z,_,C,T), not end(Z,C,_), T<h.

end_of_path(Z,T) :- end(Z,C,_), move(Z,_,C,T).
:- not end_of_path(_,_).

:- move(Z,C,C',T), move(Z,C',C'',T+1), d(C,C',D), not p(C',C'',D).

#show.
#show path(Z,C,T-1) : move(Z,C,_,T).
#show path(Z,C,T  ) : move(Z,_,C,T).
