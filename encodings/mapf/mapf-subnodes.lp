#include "../aux/aux.lp".
#include "../translations/subnodes.lp".

% States are "subnodes" (X,Y,D): being at cell (X,Y) about to head out via D.
% edge/2 (from subnodes.lp) already only connects subnodes whose D->D'
% transition is valid at the destination cell, so hyperedge legality is
% baked into the state space itself -- no separate hyperedge check needed.

         _agent(A) :- start(A,_,_,_).
_start(A,start(A)) :- start(A,_,_,_).
      _goal(A,goal(A)) :- end(A,_,_).

% agents have not yet entered the grid at T=0 (avoids spurious collisions
% between trains that happen to share a starting cell before departure)
                _edge(S,S') :- edge(S,S').
_edge(start(A),(X,Y,D)) :- start(A,(X,Y),_,D).
_edge((X,Y,D),goal(A)) :- end(A,(X,Y),_), node((X,Y,D)).

% if A is at its goal cell then move to the absorbing goal(A) state next
:- end(A,(X,Y),_), at(A,(X,Y,D),T), not move(A,(X,Y,D),goal(A),T+1), T<h+2.

%#heuristic move(A,B,C,D). [1000-D,true]

%%%
%%% MAPF encoding
%%%

% guess moves (no movement before earliest departure E is folded into the
% time range here -- purely static, so it stays a grounding-time restriction)
{ move(A,S,S',T): _edge(S,S') } <= 1 :- start(A,_,E,_), T=E+1..h+2.

% infer _agent positions
at(A,S,0) :- _start(A,S).
at(A,S,T) :- move(A,_,S,T), T=1..h+2.
at(A,S,T) :- at(A,S,T-1), not move(A,S,_,T), T=1..h+2.

pos(A,(X,Y),T) :- at(A,(X,Y,D),T).
movepos(A,(X,Y),(X',Y'),T) :- move(A,(X,Y,D),(X',Y',D'),T).

% ensure path-like strolls
:- move(A,S,_,T), not at(A,S,T-1).
:- _goal(A,U), not at(A,U,h+2).

% handle vertex/swap/follow conflicts (checked on physical cells, not subnodes)
:- { pos(A,(X,Y),T) } > 1, cell((X,Y),_), T=0..h+2.
:- movepos(A,P,P',T), movepos(B,P',P,T).

% ensure unique _agent positions (redundant/for performance)
:- { at(A,S,T) } != 1, _agent(A), T=1..h+2.

#show.
#show pos/3.
