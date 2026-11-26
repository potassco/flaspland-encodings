% input: instance + subnodes translation + path/3 facts from a solver run
_start(Z,(X,Y,D)) :- start(Z,(X,Y),_,D).
_end(Z,(X,Y,D))   :- end(Z,(X,Y),_), node((X,Y,D)).

% follow each train from its start subnode
reach(Z,C)  :- _start(Z,C).
reach(Z,C') :- reach(Z,C), path(Z,C,C').

violation(not_an_edge(Z,C,C'))   :- path(Z,C,C'), not edge(C,C').
violation(no_start(Z))           :- _start(Z,C), not path(Z,C,_).
violation(misses_end(Z))         :- train(Z), not reach(Z,C) : _end(Z,C).
violation(unreachable(Z,C,C'))   :- path(Z,C,C'), not reach(Z,C).
violation(branch(Z,C))           :- path(Z,C,C1), path(Z,C,C2), C1 < C2.
violation(leaves_end(Z,C))       :- path(Z,C,_), _end(Z,C).

length(Z,N) :- train(Z), N = #count{ C : path(Z,C,_) }.
shared(Z,Z',(X,Y)) :- path(Z,_,(X,Y,_)), path(Z',_,(X,Y,_)), Z < Z'.
shared_cells(Z,Z',N) :- shared(Z,Z',_), N = #count{ P : shared(Z,Z',P) }.

#show violation/1.
#show length/2.
#show shared_cells/3.
