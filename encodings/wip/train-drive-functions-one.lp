#const h = 3.

{ drive(Z,C,C',T) : edge(C,C'); drive(Z,C,C,T) : node(C) } = 1 :- time(Z,T), not depart(Z,T).

:- drive(Z,C,_,T), not start(Z,C,_,_), depart(Z,T-1).
:- drive(Z,C,_,T), not drive(Z,_,C,T-1), time(Z,T), not depart(Z,T-1).

% stale(Z,T  ) :- start(Z,_,_,_), depart(Z,T).
% stale(Z,T+1) :- start(Z,C,_,_), stale(Z,T), drive(Z,C,C,T+1).
% move(Z,T+1) :- stale(Z,T), not stale(Z,T+1).
move(Z,T) :- T = #min { T' : start(Z,C,_,_), drive(Z,C,C',T'), C!=C' }, time(Z,T).

:- drive(Z,C,C',T), connected(C,D,C'), not start(Z,C,_,D), move(Z,T).

:- drive(Z,C,C',T), drive(Z,C,C',T'), T>T'.

arrive(Z,T) :- end(Z,C,_), drive(Z,_,C,T).
:- not arrive(_,_).

:- drive(Z,C,C',T), drive(Z,C',C'',T+1), d(C,C',D), not p(C',C'',D).

% #show.
#show at(Z,C,T)   : drive(Z,C,_,T).
#show at(Z,C,T+1) : drive(Z,_,C,T).
