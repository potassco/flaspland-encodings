#include "../../aux/aux.lp".

% #const h = 3.

#const allow_repetitions = 1.

% paths must have length greater than one.
:- h = 0.

time(0..h).

train(Z) :- start(Z,_,_,_).

:- train(Z), not end_of_path(Z,_).
