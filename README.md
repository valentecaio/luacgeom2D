## luacompgeom2D

luacompgeom2D is a Lua implementation of some 2D computational geometry algorithms, such as:

- Enclosing Circle
- Convex Hull
- Dual Graph Mesh
- Delunay Triangulation

Each set of algorithms is implemented in a separate file in the `algorithms/` directory. 
Each algorithm has a corresponding example in `examples/`.

The results are visualized using `matplotlua`, a Lua binding to the matplotlib library.

### matplotlua

`matplotlua` is a Lua binding to the matplotlib library.
It works by keeping the plot state in a Lua table that is dumped to JSON and loaded by a Python script that generates the plot using matplotlib.
The library is self-contained in the `matplotlua/` directory and can be used independently of this repository. It can draw points, lines, curves, polygons and graphs. A simple usage example is shown in matplotlua/main.lua.



### Algorithms

#### Enclosing Circle
Enclosing circle algorithms find the smallest circle that contains all the points in a set. This is useful for many applications, such as collision detection. This repository contains several implementations of enclosing circle algorithms:
[More on the enclosing circle problem here](./Enclosing_Circle.pdf).

Available algorithms:
- Dumb algorithm - O(n), poor results 
- Brute Force - O(n^4), optimal results
- Heuristic - O(n), good results, but not optimal
- Welzl's algorithm - O(n) (statistically), optimal results
- Smolik's algorithm - O(n) (statistically), optimal results, fastest method

![enclosing_circle](figures/enclosing_circle-smolik.png?raw=true "Enclosing Circle")



#### Convex Hull
Convex hull algorithms find the smallest convex polygon that contains all the points in a set. This repository contains two implementations of convex hull algorithms:
[More on the convex hull problem here](./Convex_Hull.pdf).

Available algorithms:
- Jarvis March (Gift Wrapping) - O(nh) where h is the number of points in the hull
- Skala's algorithm - O(n) in practice for most cases

![convex_hull](figures/convex_hull-jarvis-dataset1.gif?raw=true "Convex Hull")



#### Dual Graph Mesh
A dual graph mesh is a graph where the vertices are the faces of the original graph and the edges are the shared edges between the faces. This is useful for mesh processing algorithms, including Delunay triangulation. This repository contains a simple implementation of a dual graph mesh.
[More on the dual graph mesh problem here](./Dual_Graph_Mesh.pdf).

![dual_mesh](figures/dual_mesh.png?raw=true "Dual Graph Mesh")



#### Delunay Triangulation
Delunay triangulation is a triangulation of a set of points such that no point is inside the circumcircle of any triangle.
[More on the Delaunay triangulation problem here](./Delaunay_Triangulation.pdf).

Available algorithms:
- Bowyer-Watson - O(n^2) in this implementation. Could be O(nlogn) using a topological data structure.



### Installation

    # Lua deps
    apt install lua5.3 lua-cjson lua-argparse
    
    # Python deps (only necessary for plotting)
    apt install python-is-python3 python3-matplotlib

    # imagemagick (only necessary to generate gif images)
    apt install imagemagick-6.q16  
