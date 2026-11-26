% Listing 4
#edge ((Z,C),(Z,C'))    : path(Z,C,C').
#edge ((Z,C'),(Z',(X,Y,D'))) : resolve(Z,Z',(X,Y)), path(Z,(X,Y,_),C'), path(Z',_,(X,Y,D')).
