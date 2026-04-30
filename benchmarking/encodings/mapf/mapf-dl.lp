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

#const edge=0.

% no movement before earliest departure
&diff{0 - (A,U)} <= -D :- start(A,U,D,_), edge!=1. % not possible with #edge
                                                   % unless we add D nodes per Agent

% if A is at its _goal U then move to _goal(A) in the next step
% not needed  

% Check hyperedges
:- move(A,U,V), move(A,V,W), not hyperedge(U,V,W), 
   not _start(_,U), not _goal(_,W).

% For performance?
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

#edge ((A,U),(A,V)) : move(A,U,V),                 edge = 1. 
#edge ((A,V),(B,U)) : resolve(A,B,U), move(A,U,V), edge = 1.
%
&diff{(A,U) + 1} <= (A,V) :- move(A,U,V),                    edge != 1. 
&diff{(A,V) + 0} <= (B,U) :- resolve(A,B,U), move(A,U,V),    edge != 1.
:- move(A,U,V), move(B,V,U), resolve(A,B,U), resolve(B,A,V), edge != 1.

#show.
#show move/3.
