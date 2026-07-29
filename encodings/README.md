# Encodings

## Directory preview
- 📂 [aux](#aux)
    - `aux.lp`
    - `directions.lp`
    - `grid-functions.lp`
    - `tracks.lp`
- 📁 [base](#base)
- 📁 [extensions](#extensions)
- 📁 [mapf](#mapf)
- 📂 [pathfinding](#pathfinding)
    - 📁 move2drive
    - 📁 move2path
    - 📁 path2drive
- 📂 [translations](#translations)
    - `edge-functions.lp`
    - `hypergraph.lp`
    - `subnodes.lp`
- 📁 [wip](#wip)

## Information

<a name="aux"></a>
### `aux`
The `aux` files should remain unchanged. 
These include the necessary components for constructing the topology of the environments:
- `directions.lp` defines the cardinal directions, as well as the relative rotations and offsets
- `grid-functions.lp` defines adjacency, connectedness, and valid transitions
- `tracks.lp` defines the physical connections between different track types

`aux.lp` can be invoked as an `#include` statement in an encoding as shorthand for referencing all three files.


<a name="base"></a>

<a name="extensions"></a>

<a name="mapf"></a>

<a name="pathfinding"></a>

<a name="translations"></a>

<a name="wip"></a>
