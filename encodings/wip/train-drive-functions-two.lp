#const h = 3.

{ drive(Z,C,C',T) : edge(C,C') } <= 1 :- time(Z,T), not depart(Z,T).

at(Z,C, T) :- start(Z,C,_,_), depart(Z,T).
at(Z,C',T) :- drive(Z,C,C',T), time(Z,T).
at(Z,C, T) :- at(Z,C,T-1), not drive(Z,C,_,T), time(Z,T).

:- drive(Z,C,_,T), not at(Z,C,T-1).

% move(Z,T+1) :- T = #min { T' : start(Z,C,_,_), at(Z,C',T'), C!=C' }, time(Z,T).
move(Z,T+1) :- T = #min { T' : start(Z,C,_,_), drive(Z,C,_,T') }, time(Z,T).

:- drive(Z,C,C',T), connected(C,D,C'), not start(Z,C,_,D), move(Z,T).

:- drive(Z,C,C',T), drive(Z,C,C',T'), T>T'.

arrive(Z,T) :- end(Z,C,_), drive(Z,_,C,T).
:- not arrive(_,_).

% :- drive(Z,C,C',T), drive(Z,C',C'',T+1), d(C,C',D), not p(C',C'',D).
:- at(Z,C,T-1), at(Z,C',T), at(Z,C'',T+1), d(C,C',D), C'!=C'', not p(C',C'',D).

% #show at/3.
