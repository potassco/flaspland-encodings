2 { select_train(Z) : train(Z) }.

#show.
#show train(Z) 		: select_train(Z).
#show start(Z,C,T,D) 	: start(Z,C,T,D), select_train(Z).
#show end(Z,C,T) 	: end(Z,C,T), select_train(Z).