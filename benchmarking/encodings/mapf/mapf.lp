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
:- start(A,_,E,_), move(A,_,_,T), T<E+1.

% if A is at its _goal U then move to _goal(A) in the next step
:- end(A,U,_), at(A,U,T), not move(A,U,goal(A),T+1), T<h.

% Check hyper _edges
moved(U,V,T) :-  move(A,X,V,T), X  = start(A), start(A,V,_,D), connected(U,D,V).
moved(U,V,T) :-  move(A,U,V,T), U != start(A), not end(A,V,_).
moved(U,V,T) :- moved(U,V,T-1), not move(_,V,_,T), T<=h. 
             :- moved(W,U,T-1), move(_,U,V,T), not hyperedge(W,U,V).

%%%
%%% MAPF encoding
%%% 

% guess moves
{ move(A,U,V,T): _edge(U,V) } <= 1 :- _agent(A), T=1..h.

% infer _agent positions
at(A,U,0) :- _start(A,U).
at(A,V,T) :- move(A,_,V,T), T=1..h.
at(A,U,T) :- at(A,U,T-1), not move(A,U,_,T), T=1..h.

% ensure path-like strolls
:- move(A,U,_,T), not at(A,U,T-1).
:- _goal(A,U), not at(A,U,h).

% handle _vertex/swap/follow conflicts
:- { at(A,U,T) } > 1, _vertex(U), T=0..h.
:- move(_,U,V,T), move(_,V,U,T).
% :- at(A,U,T), at(B,U,T+1), A!=B, m=fc.

% ensure unique _agent positions (redundant/for performance)
:- { at(A,U,T) } != 1, _agent(A), T=1..h.
         
#show.
#show at/3.

