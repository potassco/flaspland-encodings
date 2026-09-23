% ---------- track type mapping ----------
type_01(32800; 1025).
type_01a(4608; 16386; 72; 2064).
type_02(37408; 17411; 32872; 3089; 49186; 1097; 34864; 5633).
type_03(33825).
type_04(38433; 50211; 33897; 35889).
type_05(38505; 52275).
type_06(20994; 16458; 2136; 6672).

% ---------- switches ----------
switch(V) :- type_02(V).
switch(V) :- type_04(V).
switch(V) :- type_05(V).
switch(V) :- type_06(V).

non_switch(V) :- type_01(V).
non_switch(V) :- type_01a(V).
non_switch(V) :- type_03(V).

% ---------- counts ----------
num_type_01(N)  :- N = #count { C : cell(C,V), type_01(V)  }.
num_type_01a(N) :- N = #count { C : cell(C,V), type_01a(V) }.
num_type_02(N)  :- N = #count { C : cell(C,V), type_02(V)  }.
num_type_03(N)  :- N = #count { C : cell(C,V), type_03(V)  }.
num_type_04(N)  :- N = #count { C : cell(C,V), type_04(V)  }.
num_type_05(N)  :- N = #count { C : cell(C,V), type_05(V)  }.
num_type_06(N)  :- N = #count { C : cell(C,V), type_06(V)  }.

num_switches(N) :- N = #count { C : cell(C,V), switch(V) }.
num_non_switches(N) :- N = #count { C : cell(C,V), non_switch(V) }.
num_total(N)        :- N = S + NS, num_switches(S), num_non_switches(NS).

% ---------- minimum environment validation ----------
min_env_corner(4608; 16386; 72; 2064).

corner_present(V) :- min_env_corner(V), cell(_,V).
corner_missing(V) :- min_env_corner(V), not corner_present(V).

min_env_violated :- corner_missing(_).
min_env_ok       :- not min_env_violated.

%#show min_env_ok/0.
%#show min_env_violated/0.
%#show corner_missing/1.
#show corner_present/1.

#show num_switches/1. #show num_non_switches/1. #show num_total/1.

#show num_type_01/1.  #show num_type_01a/1. #show num_type_02/1.
#show num_type_03/1.  #show num_type_04/1.  #show num_type_05/1.
#show num_type_06/1.  
