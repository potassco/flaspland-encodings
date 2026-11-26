% Listing 4 - difcons alternative
&diff{ (Z,C) + 1 } <= (Z,C')            :- path(Z,C,C').
% Z leaves cell (X,Y) before Z' enters it
&diff{ (Z,C') + 0 } <= (Z',(X,Y,D'))    :- resolve(Z,Z',(X,Y)), path(Z,(X,Y,_),C'), path(Z',_,(X,Y,D')).
% earliest departure
&diff{ 0 - (Z,(X,Y,D')) } <= -D         :- start(Z,(X,Y),D,D').

% swap conflict (on cells: the two trains use different subnodes)
:- path(Z,(X,Y,_),(X',Y',_)), path(Z',(X',Y',_),(X,Y,_)),
   resolve(Z,Z',(X,Y)), resolve(Z',Z,(X',Y')).
