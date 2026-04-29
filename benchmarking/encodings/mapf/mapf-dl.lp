#include "../directions.lp".
#include "../grid-functions.lp".
#include "../tracks.lp".
#include "../hypergraph.lp".

         _agent(A) :- start(A,_,_,_).
_start(A,start(A)) :- start(A,_,_,_).
 _edge(start(A),U) :- start(A,U,_,_).
 _edge(       U,V) :- connected(U,_,V).
 _edge( U,goal(A)) :- end(A,U,_).
  _goal(A,goal(A)) :- end(A,_,_).
        _vertex(U) :- _edge(U,V).
        _vertex(V) :- _edge(U,V).


% no movement before earliest departure
% :- start(A,_,E,_), move(A,_,_,T), T<=E.

% if A is at its _goal U then move to _goal(A) in the next step
% :- end(A,U,_), at(A,U,T), not move(A,U,goal(A),T+1), T<h+2.

% Check hyperedges
:- move(A,U,V), move(A,V,W), not hyperedge(U,V,W), 
   not _start(_,U), not _goal(_,W).

% Not needed
% :- move(A,U,_), _start(B,U), A != B.
% :- move(A,_,U),  _goal(B,U), A != B.

%%%
%%% MAPF encoding
%%% 

% generate moves with in and out degrees of one
{ move(A,U,V): _edge(U,V) } <= 1 :- _agent(A), _vertex(V).
{ move(A,U,V): _edge(U,V) } <= 1 :- _agent(A), _vertex(U).
:-  move(A,U,_), not _start(A,U), not move(A,_,U).
:-  move(A,_,U), not  _goal(A,U), not move(A,U,_).

% fix in and out degrees of start and goal vertices
:- _start(A,U), move(A,_,U).
:-  _goal(A,U), move(A,U,_).
:- _start(A,U), not  _goal(A,U), not move(A,U,_).
:-  _goal(A,U), not _start(A,U), not move(A,_,U).

resolve(A,B,U) :- _start(A,U), move(B,_,U), A!=B. % never fires
resolve(A,B,U) :-  _goal(B,U), move(A,_,U), A!=B. % never fires
{ resolve(A,B,U);
  resolve(B,A,U) } >= 1 :- move(A,_,U), move(B,_,U), A<B.

% discard invalid orders
:- resolve(A,B,U), resolve(B,A,U). % not needed?

#edge ((A,U),(A,V)) : move(A,U,V).
#edge ((A,V),(B,U)) : resolve(A,B,U), move(A,U,V).

#show.
#show move/3.
