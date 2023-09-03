#!/usr/bin/lua

package.path = package.path .. ";../?/?.lua"

local ConvexHull = require("convex_hull")
local Plot = require("matplotlua")
local Utils = require("utils")

if not arg[1] then
  print("Usage: lua main.lua [complexity|compare|jarvis|skala]")
end

if arg[1] == "complexity" then
  local sizes = {}
  local jarvisMarchTimes = {}
  local skalaTimes = {}

  for size = 100, 50000, 200 do
    local points = Utils.generateRandomPointsInCircle(size, {x=0, y=0, r=100})
    local jarvisTime = Utils.measureExecutionTime(ConvexHull.jarvisMarch, points)
    local skalaTime = Utils.measureExecutionTime(ConvexHull.skala, points)

    table.insert(sizes, size)
    table.insert(jarvisMarchTimes, jarvisTime)
    table.insert(skalaTimes, skalaTime)
  end

  Plot.init({title = "Convex Hull Execution Time", xlabel = "Number of points", ylabel = "Time (s)"})
  Plot.addCurve(sizes, jarvisMarchTimes, "Jarvis March", "red")
  Plot.addCurve(sizes, skalaTimes, "Skala", "green")
  Plot.plot()

elseif arg[1] == "compare" then
  local points = Utils.generateRandomPointsInCircle(100, {x=0, y=0, r=100})
  local jarvisHull = ConvexHull.jarvisMarch(points)
  local skalaHull = ConvexHull.skala(points)

  Plot.init({title = "Convex Hull comparison", xlabel = "x", ylabel = "y"})
  Plot.addPointList(points)
  Plot.addPolygon(jarvisHull, "Jarvis March", "red")
  Plot.addPolygon(skalaHull, "Skala", "green")
  Plot.plot()

elseif arg[1] == "jarvis" then
  local points = Utils.generateRandomPointsInCircle(100, {x=0, y=0, r=100})
  local jarvisHull = ConvexHull.jarvisMarch(points)

  Plot.init({title = "Jarvis March Convex Hull", xlabel = "x", ylabel = "y"})
  Plot.addPointList(points)
  Plot.addPolygon(jarvisHull, "Convex Hull", "red")
  Plot.plot()

elseif arg[1] == "skala" then
  local points = Utils.generateRandomPointsInCircle(100, {x=0, y=0, r=100})
  local skalaHull = ConvexHull.skala(points)

  Plot.init({title = "Skala", xlabel = "x", ylabel = "y"})
  Plot.addPointList(points)
  Plot.addPolygon(skalaHull, "Convex Hull", "green")
  Plot.plot()
end
