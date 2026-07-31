% :- { drive(Z,C,T,_) } > 1, node(C), time(_,T).
:- drive(Z,C,T,_), drive(Z',C,T,_), Z<Z'.
:- move(_,C,C',T), move(_,C',C,T), edge(C,C'), C<C'.
