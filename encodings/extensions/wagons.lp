% Every main train is followed by a wagon. The wagon is modelled as an ordinary train,
% so the existing encodings handle (this is tempory)
%
% Works on top of any path2drive setting that uses drive-map.lp. Include it after pathfinding-*.lp and drive-map.lp.
%
% Two modes (constant wagons_in_env):
%   0 (default): the environment only contains the main trains, the wagons are derived below.
%   1: the environment already contains the wagon agents (ids N..2N-1 for main trains 0..N-1,
%      same start cell and heading as their main train); this is needed to simulate and
%      animate with `flaspland solve`, since Flatland only draws agents of the environment.
% 
% Mode 0 can be removed, as it was only used for testing.
%
% Requirement on the input: all trains of the environment have speed facts (all generated envs do).
% In mode 0 the derived wagons get no speed fact, otherwise they would count as main trains.
%
% Known bugs:
% Trains might spawn on top of eachother, this happens because the wagons are already spawned outside the environment
% and are waiting for the main train to gain distance, depanding on how the environment was generated and how many Trains
% are going to spawn in the envs., its either just a visual bug or trains colide with eachother at spawn. For this reason
% we did not exeed to spawn 6 trains and 6 wagons. And we recommend to use our already generated envs. and your settings file:
% flaspland solve envs/test/wagon-6.pkl setting-wagon.lp --time-limit 500 -- -c h=72 -c wagons_in_env=1 -c finish_margin=6
% 
% Keep in mind that this was intended for only one wagon per train, that follows at a distance,
% And that we do belive that spawning multiple wagon for one train is sustainible using this method.
% But we are totaly happy, if you give it a try and let us know how it went.

#const wagon_dist_min = 1.   % minimal following distance
#const wagon_dist_max = 6.   % maximal following distance
#const wagons_in_env  = 0.   % 1 = wagon agents are already part of the environment

% main_train(Z): trains that come from the environment (they are the ones with a speed)
% with wagons in the environment, the first half of the ids are the main trains
main_train(Z) :- speed(Z,_), wagons_in_env = 0.
main_train(Z) :- speed(Z,_), wagons_in_env = 1, 2*Z < #count{ Y : speed(Y,_) }.

% wagon_offset(N): first wagon id, wagon ids are numbered after all main trains
wagon_offset(N) :- N = #max{ Z+1 : main_train(Z) }.

% wagon(M,W): wagon W is attached to main train M (1-to-1, W = M + offset)
wagon(M,M+N) :- main_train(M), wagon_offset(N).

% mode 0: the wagon is a train that starts in the same cell and heading as its main train;
% its deadline is relaxed by the maximal distance, as it arrives later than the main train
train(W)       :- wagon(_,W), wagons_in_env = 0.
start(W,C,T,D) :- wagon(M,W), start(M,C,T,D), wagons_in_env = 0.
end(W,C,T+wagon_dist_max) :- wagon(M,W), end(M,C,T), wagons_in_env = 0.

% mode 1: the wagon agents come from the environment and must match their main train
:- wagon(M,W), wagons_in_env = 1, start(M,C,_,D), not start(W,C,_,D).
:- wagon(M,W), wagons_in_env = 1, end(M,C,_), not end(W,C,_).

% --- same trajectory -------------------------------------------------------
% the wagon visits exactly the cells of its main train, in the same order
:- wagon(M,W), path(M,C,P), not path(W,C,P).
:- wagon(M,W), path(W,C,P), not path(M,C,P).

% --- synchronized movement ------------------------------------------------
% advance(Z,T): train Z goes one step further on its path between T-1 and T
% (this includes the step from off-map, index -1, onto the start cell)
advance(Z,T) :- map(Z,T-1,P), map(Z,T,P+1).

% if the main train stops, the wagon stops as well
:- wagon(M,W), advance(W,T), map(M,T-1,P), map(M,T,P).

% once the wagon is on the map, it moves whenever its main train moves
:- wagon(M,W), advance(M,T), map(W,T-1,Q), Q >= 0, not advance(W,T).

% --- following distance --------------------------------------------------
% while the main train is on the map (index >= 0), the wagon is between wagon_dist_min
% and wagon_dist_max path steps behind it, a wagon not yet on the map counts as index -1
:- wagon(M,W), map(M,T,P), P >= 0, map(W,T,Q), P-Q < wagon_dist_min.
:- wagon(M,W), map(M,T,P), P >= 0, map(W,T,Q), P-Q > wagon_dist_max.
