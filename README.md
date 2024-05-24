## luacomputgeom2D

luacomputgeom2D is a Lua implementation of some 2D computational geometry algorithms, such as:

- Enclosing Circle
- Convex Hull
- Dual Graph Mesh
- Delaunay Triangulation

This repository also includes the `matplotlua` library, a Lua binding to the matplotlib library.  
  
It is organized as follows:  
- `algorithms/` - Contains the implementation of the algorithms;
- `matplotlua/` - Contains the matplotlua library;
- `examples/` - Contains usage examples of each algorithm;
- `reports/` - Contains reports on the algorithms implementations and their complexity.
- `figures/` - Contains images and gifs of the algorithms results. Also used as output directory for the examples.

---
### matplotlua

matplotlua is a Lua binding to the [matplotlib library](https://matplotlib.org/).  
It keeps the plot state in a Lua table until a call to `Plot.plot()` or `Plot.figure()` is made. When this happens, the state is dumped to a JSON file and a Python script is called to generate the plot using matplotlib.  
  
The library is self-contained in the `matplotlua/` directory and can be used independently of this repository. It can draw points, lines, curves, polygons and graphs.  
  
A simple usage is shown in `matplotlua/main.lua` and a more advanced one (including gif generation using imagemagick) can be found in `examples/convex_hull.lua`.  

![matplotlua](figures/matplotlua.png?raw=true "matplotlua")

---
### Installation

    # Lua deps
    apt install lua5.3 lua-cjson lua-argparse
    
    # Python deps (only necessary for plotting)
    apt install python-is-python3 python3-matplotlib

    # imagemagick (only necessary to generate step by step animations)
    apt install imagemagick-6.q16  

---
### Algorithms

#### Enclosing Circle
Enclosing circle algorithms find the smallest circle that contains all the points in a set. This is useful for many applications, such as collision detection.  
[More on the enclosing circle problem here](reports/Enclosing_Circle.pdf).  

Available algorithms:
- Dumb algorithm - O(n), poor results;
- Brute Force - O(n^4), optimal results;
- Heuristic - O(n), good results, but not optimal;
- Welzl's algorithm - O(n) (statistically), optimal results;
- Smolik's algorithm - O(n) (statistically), optimal results, fastest method.

![enclosing_circle](figures/enclosing_circle-compare.png?raw=true "Enclosing Circle")


---
#### Convex Hull
Convex hull algorithms find the smallest convex polygon that contains all the points in a set.  
[More on the convex hull problem here](reports/Convex_Hull.pdf).  

Available algorithms:
- Jarvis March (Gift Wrapping) - O(nh) where h is the number of points in the hull;
- Skala's algorithm - O(n) in practice for most cases.

![convex_hull](figures/convex_hull-jarvis-dataset1.gif?raw=true "Convex Hull")


---
#### Dual Graph Mesh
A dual graph mesh is a graph where the vertices are the faces of the original graph and the edges are the shared edges between the faces. This is useful for mesh processing algorithms, including Delunay triangulation. This repository contains a very simple implementation of a dual graph mesh.  
[More on the dual graph mesh problem here](reports/Dual_Graph_Mesh.pdf).  

![dual_mesh](figures/dual_mesh.png?raw=true "Dual Graph Mesh")


---
#### Delunay Triangulation
Delunay triangulation is a triangulation of a set of points such that no point is inside the circumcircle of any triangle.  
[More on the Delaunay triangulation problem here](reports/Delaunay_Triangulation.pdf).  

Available algorithms:
- Bowyer-Watson - O(n^2) in this implementation. Could be O(nlogn) using a topological data structure.

![delaunay](figures/delaunay1.png?raw=true "Delaunay Triangulation")


---
## Step by step plotting

Some examples can generate step by step animations of the algorithms. To do so, you need to have imagemagick installed and follow the help message of the example.

* Delaunay Bowyer-Watson algorithm step by step:  
![delaunay](figures/delaunay1.gif?raw=true "Delaunay Triangulation Step by Step")
   
* Convex Hull Jarvis algorithm step by step:   
![convex_hull](figures/convex_hull-jarvis-random-100-points.gif?raw=true "Convex Hull Step by Step")

More animations can be found in the `figures/` directory.
