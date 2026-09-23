#include "../aux/aux.lp".
#include "../translations/hypergraph.lp".

% #const h=30.

#const original_end=0.
%
_end(A,U,T) :- end(A,U,T), T<=h, original_end  = 1.
_end(A,U,h) :- end(A,U,T), T> h, original_end  = 1.
%
_end(A,U,h) :- end(A,U,T),       original_end != 1.
%
:- start(A,_,E,_), _end(A,_,T), T < E.

{ departure(A,T) : T = E..End } = 1 :- start(A,_,E,_), _end(A,_,End).

{ move(A,U,V,T): connected(U,_,V), not end(A,U,_) } 1 :- start(A,_,E,_), _end(A,_,End), T=E+1..End.

at(A,U,T) :- start(A,U,_,_), departure(A,T).
at(A,V,T) :- move(A,U,V,T).
at(A,U,T) :-   at(A,U,T-1), not move(A,U,_,T), not end(A,U,_), start(A,_,E,_), _end(A,_,End), T=E+1..End.

:- move(A,U,_,T), not at(A,U,T-1).
:- _end(A,U,T), at(A,V,T), U != V.

:- { at(A,U,T) } > 1, cell(U,_), T=0..h.
:- move(_,U,V,T), move(_,V,U,T). 

:- 2 { at(A,U,T) }, start(A,_,_,_), T=0..h.

% Check hyper edges
moved(U,V,T) :- start(A,V,_,D), departure(A,T), connected(U,D,V).
moved(U,V,T) :-  move(A,U,V,T), not _end(A,V,_).
moved(U,V,T) :- moved(U,V,T-1), not move(_,V,_,T), T<h. 
             :- moved(W,U,T-1), move(_,U,V,T), not hyperedge(W,U,V).

% Additional constraints (do not seem to be useful)
% :- move(A,_,_,T), departure(A,TT), T<=TT.
% :- move(A,_,_,T), not at(A,_,T-1).


#show.
#show at/3.
%#show drive(A,B,C) : at(A,B,C).
%#show departure/2.
%#show arrival/2.
%#show move/4.
