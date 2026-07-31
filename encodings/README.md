# Encodings

## Directory preview
- 📂 [`aux`](#aux)
    - `aux.lp`
    - `directions.lp`
    - `grid-functions.lp`
    - `tracks.lp`
- 📁 [`base`](#base)
- 📁 [`extensions`](#extensions)
- 📁 [`mapf`](#mapf)
- 📂 [`pathfinding`](#pathfinding)
    - 📁 move2drive
    - 📁 move2path
    - 📁 path2drive
- 📂 [`translations`](#translations)
    - `edge-functions.lp`
    - `hypergraph.lp`
    - `subnodes.lp`
- 📁 [`wip`](#wip)

## Information

<a name="aux"></a>
### ⭐ `aux`
The `aux` files should remain unchanged. 
These include the necessary components for constructing the topology of the environments:
- `directions.lp` defines the cardinal directions, as well as the relative rotations and offsets
- `grid-functions.lp` defines adjacency, connectedness, and valid transitions
- `tracks.lp` defines the physical connections between different track types

`aux.lp` can be invoked as an `#include` statement in an encoding as shorthand for referencing all three files:

```
#include "./aux/aux.lp".
...
```
<a name="base"></a>
### `base`
The `base` files were migrated over from the first round of benchmarking.
The encodings here were adopted from the Routing and Scheduling paper,
and were modified to handle the directionality of the trains.

---

<a name="extensions"></a>
### `extensions` 
The `extensions` are currently a work-in-progress.
The goal is to introduce modularity to encodings,
for instance by optionally allowing for optimization or collision-handling.

These extensions can be invoked as an `#include` statement in an encoding:

```
#include "./extensions/optimization.lp".
...
```

---

<a name="mapf"></a>
### `mapf`
The `base` files were migrated over from the first round of benchmarking.
The encodings here were adopted from the Routing and Scheduling paper,
and were modified by adding wrappers that translate the Flatland environment
into a MAPF environment.

---

<a name="pathfinding"></a>
### `pathfinding`
The `pathfinding` directory includes both files and sub-directories.
There are simple files in here that handle basic pathfinding without collisions
for each environment representation.

---

<a name="translations"></a>
### ⭐ `translations`
The `translation` files should remain unchanged.
The encodings here convert a Flatland environment,
represented according to our established fact format,
from a grid into the corresponding graph representation.

---

<a name="wip"></a>
### `work in progress`
Pathfinding or other encodings that have not yet been tested should be kept in the `wip` folder.
