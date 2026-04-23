% vertex collisions
:- { drive(Z,C,T) } > 1, node(C), time(_,T).

% edge collisions
move(C,C',T) :- drive(Z,C,T-1), drive(Z,C',T).
:- move(_,C,C',T), move(_,C',C,T), edge(C,C'), C<C'.
