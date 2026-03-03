% vertex conflict
:- drive(Z,_,C,T), drive(Z',_,C,T), Z > Z'.

% edge conflict
:- drive(Z,C,C',T), drive(Z',C',C,T).