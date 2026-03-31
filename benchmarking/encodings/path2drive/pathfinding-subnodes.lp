% This encoding derives paths with length <= h between start and end cells of trains,
% taking into account the train's starting orientation

#include "../subnodes.lp".
#include "pathfinding-common.lp".

path'(Z,(X,Y,D),0) :- start(Z,(X,Y),_,D).

{ path'(Z,C',T+1) : edge(C,C') } = 1 :- path'(Z,C,T), time(T+1), not end_of_path(Z,T).

:- allow_repetitions=0, path'(Z,C,T), path'(Z,C,T'), T>T'.

path(Z,(X,Y),T) :- path'(Z,(X,Y,D),T).

end_of_path(Z,T) :- end(Z,(X,Y),_), path(Z,(X,Y),T).
