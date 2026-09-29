# `flaspland` encodings

Our tool `flaspland` is a framework that acts as an interface between Flatland-RL code written in Python and Answer Set Programming in clingo.
Users can write ASP encodings in clingo that solve the Flatland problem and use `flaspland` to translate their output into Flatland actions to interact with the environment.

In this repository, we provide a collection of encodings that can be used to solve various degrees of the Flatland problem. The repository adheres to the following structure:
* 📁 `benchmarking`
* 📁 `encodings`
  * 📁 `aux` files that describe the physics of Flatland environments
  * 📁 `base` files with baseline encodings derived from the R&S paper
  * 📁 `extensions` modular extensions for encodings such as collisions and optimization
  * 📁 `mapf` files with mapf encodings derived from the R&S paper
  * 📁 `pathfinding` files that contain logic for finding paths within a given Flatland environment
  * 📁 `translations` files that convert a given Flatland environment into an alternative graph representation
  * 📁 `wip` files that are currently a work-in-progress
* 📁 `envs`
  * 📁 `benchmarks` official benchmark environments from the Flatland challenge
* 📝 `setting-*.lp` a clingo encoding that organizes various subprograms into a single file

---

## How to use

Flaspland encodings are designed to be modular -- this means that each program handles a specific task.
The benefit of this is that you can swap out pieces of functionality without altering the rest of the code.

The easiest way to run encodings is to create a `setting` file. Check out an example, `setting-sub.lp`:

```
% environment physics
#include "encodings/aux/aux.lp".

% specific approach
#include "encodings/translations/subnodes.lp".
#include "encodings/pathfinding/path2drive/pathfinding-subnodes.lp".
#include "encodings/pathfinding/path2drive/drive-map.lp".
#include "encodings/pathfinding/path2drive/drive-collisions.lp".
```

In this file, a few components are included:
* `aux.lp` to account for the physics of the environment
* `subnodes.lp` to translate the standard environment into a graph structure
* `pathfinding-subnodes.lp` to find paths for trains in the environment
* `drive-map.lp` to add waits to the found paths
* `drive-collisions.lp` to handle collision avoidance

The files in this repository may be used so that more interesting questions can be addressed.
In most cases, `aux.lp` should always be included, unless the physics of the environment are to be implemented differently.
In general, approaches need some way of finding trajectories for the agents and handling collisions.
Translations to graphs are optional but recommended.
Other potential modules include optimization, speed, graph compression, prioritization, etc.

When you are ready to run your encoding, you can easily call the `setting` file along with an environment, for example:
```
$ clingo setting-custom.lp envs/example.lp
```
