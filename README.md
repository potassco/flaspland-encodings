# `flaspland` encodings

Our tool `flaspland` is a framework that acts as an interface between Flatland-RL code written in Python and Answer Set Programming in clingo.
Users can write ASP encodings in clingo that solve the Flatland problem and use `flaspland` to translate their output into Flatland actions to interact with the environment.

In this repository, we provide a collection of encodings that can be used to solve various degrees of the Flatland problem. The repository adheres to the following structure:
* 📁 `encodings`
  * 📁 `aux` files that describe the physics of Flatland environments
  * 📁 `graph-translations` files that convert a given Flatland environment into an alternative graph representation
  * 📁 `pathfinding` files that contain logic for finding paths within a given Flatland environment
* 📁 `envs`
  * 📁 `benchmarks` official benchmark environments from the Flatland challenge
* 📝 `setting-*.lp` a clingo encoding that organizes various subprograms into a single file
