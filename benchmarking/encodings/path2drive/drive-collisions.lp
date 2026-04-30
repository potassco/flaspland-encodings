% vertex collisions
% :- drive(Z,C,T), drive(Z',C,T), Z < Z'.
:- cell(C,_), 2 { drive(Z,C,T) }, T=1..h.

% edge collisions
%:- drive(Z,C,T), drive(Z,C',T+1), drive(Z',C',T), drive(Z',C,T+1), Z < Z'.

move(Z,(X,Y),(X',Y'),T) :- edge((X,Y,D),(X',Y',D')), drive(Z,(X,Y),T-1), drive(Z,(X',Y'),T).
:- move(_,U,V,T), move(_,V,U,T).

%path(Z,C,T),,n
