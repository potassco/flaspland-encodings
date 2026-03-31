hyperedge(C,C',C'') :- connected(C,D,C'), connected(C',D',C''), cell(C',T), transition(T,(D,D')).

node(C;C';C'') :- hyperedge(C,C',C'').
