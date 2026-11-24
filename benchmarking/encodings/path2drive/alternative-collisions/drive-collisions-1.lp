% vertex collisions
:- { drive(Z,C,T) } > 1, node(C).

% edge collisions
:- drive(Z,C,T), drive(Z,C',T+1), drive(Z',C',T), drive(Z',C,T+1), Z < Z'.
