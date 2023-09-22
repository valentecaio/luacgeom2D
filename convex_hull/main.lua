#!/usr/bin/lua

package.path = package.path .. ";./?/?.lua"
package.path = package.path .. ";../?/?.lua"
local Plot = require("matplotlua")
local Utils = require("utils")
local ConvexHull = require("convex_hull")


local cmds = {"complexity", "compare", "jarvis", "graham", "skala"}
local cmds_str = table.concat(cmds, "|")
local function print_help_and_quit()
  print("Usage: lua " .. arg[0] .. " <method> [dataset]\
  where <method> is one of [" .. cmds_str .. "]\
  and [dataset] is a file containing points in the format of cloud1.txt")
  os.exit()
end

-- validate args
if (#arg < 1) or (not string.find(cmds_str, arg[1])) then
  print_help_and_quit()
end

method_name = arg[1]
if arg[2] then
  local dataset_str = assert(io.open(arg[2], "r")):read("*all")
  dataset = Utils.readPointsFromString(dataset_str)
end

if method_name == "complexity" then
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

elseif method_name == "compare" then
  local points = Utils.generateRandomPointsInCircle(100, {x=0, y=0, r=100})
  local jarvisHull = ConvexHull.jarvisMarch(points)
  local skalaHull = ConvexHull.skala(points)

  Plot.init({title = "Convex Hull comparison", xlabel = "x", ylabel = "y"})
  Plot.addPointList(points)
  Plot.addPolygon(jarvisHull, "Jarvis March", "red")
  Plot.addPolygon(skalaHull, "Skala", "green")
  Plot.plot()

elseif dataset then
  local method
  if method_name == "jarvis" then
    method = ConvexHull.jarvisMarch
  elseif method_name == "graham" then
    method = ConvexHull.graham
  elseif method_name == "skala" then
    method = ConvexHull.skala
  else
    print_help_and_quit()
  end

  local time, hull = Utils.measureExecutionTime(method, dataset)
  -- print("Found hull: " .. Utils.tableToString(hull))
  print("Execution time: " .. time .. " seconds")
  -- print("Is this a valid result? " .. tostring(ConvexHull.validateHull(hull, dataset)))
  Plot.init{title = "Convex Hull (method: " .. method_name .. ", dataset: " .. arg[2] .. ")"}
  Plot.addPointList(dataset)
  Plot.addPolygon(hull, method_name, "green")
  Plot.plot()

else
  print_help_and_quit()
end
