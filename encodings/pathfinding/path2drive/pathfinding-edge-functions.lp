% This encoding derives paths with length <= h between start and end cells of trains,
% taking into account the train's starting orientation

#include "../../translations/edge-functions.lp".
#include "pathfinding-common.lp".

% we enforce that the starting position and direction is respected
path(Z,C, 0;
     Z,C',1) :- start(Z,C,_,D), adjacent(C,D,C').

{ path(Z,C',T+1): edge(C,C') } = 1 :- path(Z,C,T), time(T+1), not end_of_path(Z,T).

:- allow_repetitions=0, path(Z,C,T), path(Z,C',T+1), path(Z,C,T'), path(Z,C',T'+1), T>T'.

end_of_path(Z,T) :- end(Z,C,_), path(Z,C,T).

:- path(Z,C,T), path(Z,C',T+1), path(Z,C'',T+2), d(C,C',D), not p(C',C'',D).
