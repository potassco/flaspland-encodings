% :- { move(Z,_,C,T) } > 1, node(C), time(_,T).
:- move(Z,_,C,T),  move(Z',_,C,T), Z<Z'.
:- move(_,C,C',T), move(_,C',C,T), edge(C,C'), C<C'.
