%  path(Z,C,P)
% drive(Z,C,D)

#const h = 10.
% start(Z,P) :- path(Z,_,_), P = #min{ P' : path(Z,_,P) }.
#const s = 1.
time(s..h).

% { map(Z,P,D) : time(D) } = 1 :- start(Z,S)
{ map(Z,P,D) : time(D) } = 1 :- path(Z,_,P).
:- map(Z,P,D), map(Z,P+1,D'), path(Z,_,P+1), D'<=D.

#show map/3.
