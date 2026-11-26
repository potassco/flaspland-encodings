% need to account for directions inside of subnodes
_start(Z,(X,Y,D)) :- start(Z,(X,Y),_,D).
_end(Z,(X,Y,D))   :- end(Z,(X,Y),_), node((X,Y,D)).
_arrived(Z)       :- _end(Z,C), path(Z,_,C).

% Listing 2
{ path(Z,C,C') : edge(C,C') } <= 1 :- train(Z), node(C).
{ path(Z,C,C') : edge(C,C') } <= 1 :- train(Z), node(C').

:- path(Z,C,C'), not _start(Z,C), not path(Z,_,C).
:- path(Z,C,C'), not _end(Z,C'),  not path(Z,C',_).

:- path(Z,_,C), _start(Z,C).
:- path(Z,C,_), _end(Z,C).
:- _start(Z,C), not path(Z,C,_).
:- train(Z), not _arrived(Z).