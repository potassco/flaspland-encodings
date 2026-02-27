{ depart(Z,T..h-1) } = 1 :- start(Z,_,T,_).

time(Z,T) :- depart(Z,T).
time(Z,T+1) :- time(Z,T), not arrive(Z,T), T<h.
