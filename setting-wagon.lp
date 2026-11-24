% Setting for environments with many trains (e.g. 6 main trains + 6 wagons).
% Same as setting-sub.lp, but with the compact collision encoding, which grounds far smaller
% when there are many trains, plus the wagons.

% environment physics
#include "encodings/aux/aux.lp".

% specific approach
#include "encodings/constant.lp".
#include "encodings/translations/subnodes.lp".
#include "encodings/pathfinding/path2drive/pathfinding-subnodes.lp".
#include "encodings/pathfinding/path2drive/drive-map.lp".
#include "encodings/pathfinding/path2drive/drive-collisions-compact.lp".

#include "encodings/extensions/wagons.lp".

% finish_margin: all trains must be done this many steps before the horizon h, so that the
% flaspland simulation (which stops with the plan) still shows every arrival. 0 = no margin.
#const finish_margin = 0.
:- drive(_,_,T), T > h-finish_margin.
#include "encodings/actions/drive-to-actions.lp".
