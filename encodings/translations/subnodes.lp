node((X,Y,D)) :- cell((X,Y),T), transition(T, (_,D)).

edge((X,Y,D), (X',Y',D')) :-
    node((X,Y,D)), node((X',Y',D')),
    connected((X,Y),D,(X',Y')),
    cell((X',Y'), T'), transition(T', (D,D')).
