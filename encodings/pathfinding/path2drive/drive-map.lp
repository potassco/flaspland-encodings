  
  map(Z,D-1, -1)   :- start(Z,_,D,_).
{ map(Z,D+1,P  ) } :-  map(Z,D,P), not end_of_path(Z,P), D<h.
  map(Z,D+1,P+1)   :-  map(Z,D,P), not map(Z,D+1,P), path(Z,_,P+1), D<h.
                   :- path(Z,_,P), not map(Z,  _,P).
      drive(Z,C,D) :- path(Z,C,P), map(Z,D,P).

% #show drive/3.
