{ move(A,U,V) : edge(U,V) } <= 1 :- agent(A), vertex(V).
{ move(A,U,V) : edge(U,V) } <= 1 :- agent(A), vertex(U).
:- move(A,U,_), not start(A,U), not move(A,_,U).
:- move(A,_,U), not goal(A,U), not move(A,U,_).

:- start(A,U), move(A,_,U).
:- goal(A,U),  move(A,U,_).
:- start(A,U), not goal(A,U), not move(A,U,_).
:- goal(A,U),  not start(A,U), not move(A,_,U).