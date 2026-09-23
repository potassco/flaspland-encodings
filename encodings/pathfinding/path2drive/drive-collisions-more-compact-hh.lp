% vertex collisions
% :- drive(Z,C,T), drive(Z',C,T), Z < Z'.
:- cell(C,_), 2 { drive(Z,C,T) }, T=1..hh.

% edge collisions
%:- drive(Z,C,T), drive(Z,C',T+1), drive(Z',C',T), drive(Z',C,T+1), Z < Z'.
move((X,Y),(X',Y'),T) :- connected((X,Y),D,(X',Y')), drive(Z,(X,Y),T-1), drive(Z,(X',Y'),T).
:- move(U,V,T), move(V,U,T), U < V.
