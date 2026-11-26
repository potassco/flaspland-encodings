% Listing 4 - boolean alternative with transitive closure
sequence((Z,C),(Z,C'))  :- path(Z,C,C').
% Z leaves cell (X,Y) before Z' enters it
sequence((Z,C'),(Z',(X,Y,D'))) :- resolve(Z,Z',(X,Y)), path(Z,(X,Y,_),C'), path(Z',_,(X,Y,D')).

closure(U,V) :- sequence(U,V).
closure(U,W) :- closure(U,V), sequence(V,W).
:- closure(U,U).