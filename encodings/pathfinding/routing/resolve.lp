% Listing 3 - trains are ordered by cell (X,Y), not by subnode (X,Y,D)
resolve(Z,Z',(X,Y))             :- _start(Z,(X,Y,_)), path(Z',_,(X,Y,_)), Z != Z'.
% resolve(Z,Z',(X,Y))             :-   _end(Z',(X,Y,_)), path(Z,_,(X,Y,_)), Z != Z'.
resolve(Z,Z',(X,Y))             :- _end(Z',(X,Y,_)), 
                                    path(Z,_,(X,Y,_)), Z != Z', 
                                    not _end(Z,(X,Y,_)).

{ resolve(Z,Z',(X,Y)) ;
  resolve(Z',Z,(X,Y)) } >= 1    :- path(Z,_,(X,Y,_)), path(Z',_,(X,Y,_)), Z < Z'.
                                :- resolve(Z,Z',C), resolve(Z',Z,C).

