#!/usr/bin/lua

package.path = package.path .. ";../algorithms/?.lua"
package.path = package.path .. ";../matplotlua/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")
local Delaunay = require("delaunay")


----------- SCRIPT SETUP -----------

GIF = false              -- generate ste-by-step gif image
DEBUG = false            -- print debug messages
OUT_DIR = "../figures/"  -- output directory for plots and gifs

local filepath = arg[1] or "../datasets/delaunay1.txt"


----------- MAIN -----------

Plot.init{title = "Delaunay Triangulation"}

-- run algorithm
if GIF then
  PLOT = GIF
  local points = Utils.readPointsFromFile(filepath)
  local mesh = Delaunay.incremental(points)
  local filename = Plot.generateGif(nil, OUT_DIR, 50)
  print("Gif saved at " .. filename)
else
  local points = Utils.readPointsFromFile(filepath)
  local mesh = Delaunay.incremental(points)

  -- plot results
  Plot.addPointList(points, "red")
  for _,t in ipairs(mesh) do
    Plot.addPolygon(t.vertices, nil, "blue")
  end
  Plot.plot()
  -- Plot.figure(OUT_DIR .. "delaunay1.png")
end
