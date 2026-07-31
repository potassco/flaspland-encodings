% :- { drive(Z,(X,Y,_),T) } > 1, node((X,Y,_)), time(_,T).
:- drive(Z,(X,Y,_), T), drive(Z',(X,Y,_),T), Z<Z'.
:- move(_,(X,Y,_),(X',Y',_),T), move(_,(X',Y',_),(X,Y,_),T), (X,Y) < (X',Y').
