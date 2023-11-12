#!/usr/bin/lua

package.path = package.path .. ";./?/?.lua"
package.path = package.path .. ";../?/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")
local Delaunay = require("delaunay")


----------- SCRIPT SETUP -----------

DEBUG = false             -- print debug messages
PLOT = false              -- plot each step of the algorithm
plot_method = Plot.figure -- Plot.figure or Plot.plot

local filepath = arg[1] or "nuvem1.txt"


----------- MAIN -----------

Plot.init{title = "Delaunay Triangulation"}

-- points
local points = Utils.readPointsFromFile(filepath)
local mesh = Delaunay.incremental(points)

Plot.addPointList(points, "red")
for _,t in ipairs(mesh) do
  Plot.addPolygon(t.vertices, nil, "blue")
end

Plot.plot()
