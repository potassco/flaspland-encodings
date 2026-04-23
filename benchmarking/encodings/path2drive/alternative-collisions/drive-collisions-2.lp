% vertex collisions
:- drive(Z,C,T), drive(Z',C,T), Z < Z'.

% edge collisions
move(C,C',T) :- drive(Z,C,T-1), drive(Z,C',T).
:- move(_,C,C',T), move(_,C',C,T), edge(C,C'), C<C'.



