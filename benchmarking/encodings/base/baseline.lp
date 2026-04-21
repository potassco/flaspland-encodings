#include "../directions.lp".
#include "../grid-functions.lp".
#include "../tracks.lp".

#const h=30.

{ departure(Z,Dep) : Dep = E..h } = 1 :- start(Z,_,E,_).
{ arrival(Z,Arr) : Arr = E..h } = 1 :- start(Z,_,E,_).
:- departure(Z,Dep), arrival(Z,Arr), Arr <= Dep.

{ move(Z,U,V,T): connected(U,_,V) } <= 1 :- departure(Z,Dep), arrival(Z,Arr), T=Dep..Arr.


at(Z,U,D,Dep)   :-  departure(Z,Dep), start(Z,U,_,D).
at(Z,V,D,T)     :-  move(Z,U,V,T), connected(U,D,V),
                    departure(Z,Dep), arrival(Z,Arr), T = Dep+1..Arr.
at(Z,U,D,T)     :-  at(Z,U,D,T-1), not move(Z,U,_,T), 
                    departure(Z,Dep), arrival(Z,Arr), T=Dep+1..Arr.

:- arrival(Z,Arr), end(Z,Goal,_), not at(Z,Goal,_,Arr).

:- move(Z,U,V,_), at(Z,V,D,_), not connected(U,D,V).
% :- start(Z,U,_,D), move(Z,U,V,_), not connected(U,D,V).                                       % doesn't work, but do we need it?
% :- at(Z,U,D,T-1), move(Z,U,V,T), at(Z,V,D',T), cell(U,Track), not transition(Track,(D,D')).   % doesn't work, but do we need it?

:- move(Z,U,_,T), not at(Z,U,_,T-1).
% :- end(Z,V,_), not at(Z,V,_,_).
% :- end(Z,U,_), move(Z,U,V,_), V>U.

#show at/4.
#show departure/2.
#show arrival/2.
#show move/4.
% #show transition/2.