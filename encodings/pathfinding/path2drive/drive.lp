delay_budget(Z,h-L-S) :- start(Z,_,S,_), end_of_path(Z,L).

% delay/3 represents the cumulative delay during the drive. By abuse
% of notation, at index -1 it denotes the delay in spawning the
% train compared to the earliest starting time.
{ delay(Z,T-1,0..B) } = 1 :- path(Z,_,T), delay_budget(Z,B).

% No waiting allowed at the goal cell
delay(Z,T,D) :- end_of_path(Z,T), delay(Z,T-1,D).

% enforce monotonicity/cumulativity of delays
%:- delay(Z,T,W), delay(Z,T+1,W'), W' < W.
:- end_of_path(Z,L), T=-1..L-2, 1 #sum{ W : delay(Z,T,W); -W' : delay(Z,T+1,W') }.

% drive(Z,C,T+S+W..T+S+W') :- path(Z,C,T), start(Z,_,S,_), delay(Z,T-1,W), delay(Z,T,W').
drive(Z,C,T+S+W   ) :-  path(Z,C,T), start(Z,_,S,_), delay(Z,T-1,W).
 stop(Z,  T+S+W'+1) :-  path(Z,C,T), start(Z,_,S,_), delay(Z,T, W').
drive(Z,C,T+1     ) :- drive(Z,C,T), not stop(Z,T+1), T<h.

#show drive/3.
