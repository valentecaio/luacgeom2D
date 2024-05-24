#!/usr/bin/lua

package.path = package.path .. ";../algorithms/?.lua"
package.path = package.path .. ";../matplotlua/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")
local ConvexHull = require("convex_hull")

local argparse = require("argparse")

-- parameters for the analysis
local min_input_size = 10
local max_input_size = 20000
local step = 100

-- parse args
local parser = argparse(arg[0], "Commands:\
  algorithm    Generate and plot the convex hull for a given algorithm.\
  compare      Visually compare the results of all algorithms runnig with the same dataset.\
  complexity   Plot the execution time of the algorithms for different input sizes.\
  hull-size    Plot the size of the convex hull for different input sizes.\
  gif          Generate step-by-step gif image for a given algorithm.")
parser:argument("command",   "One of the commands above.")
parser:option("-a --alg",    "Algorithm name, one of [ jarvis | skala ]")
parser:option("-i --input",  "Data Set input file path. Omit this option to use a random dataset.")
parser:option("-n --npoints","Number of points in the random dataset.", "100")
parser:option("-d --delay",  "Delay of gif image transition in ms.", "50")
parser:option("--dir",       "Output directory for figures.", "../figures/")
local args = parser:parse()

-- read dataset from file or generate random dataset
local points = {}
if args.input then
  local dataset = assert(io.open(args.input, "r")):read("*all")
  points = Utils.readPointsFromString(dataset)
else
  args.input = args.npoints .. " random points"
  points = Utils.generateRandomPointsInCircle(args.npoints, {x=0, y=0, r=100})
end

local method_by_name = {
  incremental = ConvexHull.incremental, -- TODO
  jarvis = ConvexHull.jarvisMarch,
  graham = ConvexHull.graham, -- TODO
  skala = ConvexHull.skala
}


if args.command == "complexity" then
  local sizes = {}
  local jarvisMarchTimes = {}
  local skalaTimes = {}

  for size = min_input_size, max_input_size, step do
    local points = Utils.generateRandomPointsInCircle(size, {x=0, y=0, r=100})
    local jarvisTime = Utils.measureExecutionTime(ConvexHull.jarvisMarch, points)
    local skalaTime = Utils.measureExecutionTime(ConvexHull.skala, points)

    table.insert(sizes, size)
    table.insert(jarvisMarchTimes, jarvisTime)
    table.insert(skalaTimes, skalaTime)
  end

  Plot.init({title = "Convex Hull Execution Time (step: "..step..")", xlabel = "Number of points", ylabel = "Time (s)"})
  Plot.addCurve(sizes, jarvisMarchTimes, "Jarvis March", "red")
  Plot.addCurve(sizes, skalaTimes, "Skala", "green")
  Plot.plot()
  -- Plot.figure("../figures/convex_hull-complexity.png")


elseif args.command == "hull-size" then
  local method = method_by_name[args.alg]
  assert(method)

  local nsizes = {}
  local hsizes = {}

  for n = min_input_size, max_input_size, step do
    local points = Utils.generateRandomPointsInCircle(n, {x=0, y=0, r=100})
    local hull = method(points)
    table.insert(nsizes, n)
    table.insert(hsizes, #hull)
  end

  Plot.init({title = "Convex Hull ("..args.alg..") (step: "..step..")", xlabel = "Input size", ylabel = "Hull size"})
  Plot.addCurve(nsizes, hsizes, "Hull Size ("..args.alg..")", "red")
  Plot.plot()
  -- Plot.figure("../figures/convex_hull-hull_size.png")


elseif args.command == "compare" then
  local jarvisHull = ConvexHull.jarvisMarch(points)
  local skalaHull = ConvexHull.skala(points)

  Plot.init({title = "Convex Hull comparison", xlabel = "x", ylabel = "y"})
  Plot.addPointList(points)
  Plot.addPolygon(jarvisHull, "Jarvis March", "red")
  Plot.addPolygon(skalaHull, "Skala", "green")
  Plot.plot()
  -- Plot.figure("../figures/convex_hull-compare.png")


elseif args.command == "algorithm" then
  local method = method_by_name[args.alg]
  assert(method)

  local time, hull = Utils.measureExecutionTime(method, points)
  print("Execution time: " .. time .. " seconds")
  Plot.init{title = "Convex Hull (method: " .. args.alg .. ", dataset: " .. args.input .. ")"}
  Plot.addPointList(points)
  Plot.addPolygon(hull, args.alg, "green")
  Plot.plot()
  -- Plot.figure("../figures/convex_hull.png")


elseif args.command == "gif" then
  print("Generating gif for " .. args.alg .. " algorithm ...")
  local method = method_by_name[args.alg]
  assert(method)

  ConvexHull.gif = true
  method(points)

  local filename = Plot.generateGif(
    "Convex Hull (" .. args.alg .. ")",
    args.dir,
    args.delay
  )
  print("File saved at " .. filename)

  -- try to open gif in firefox
  -- os.execute("firefox --new-window " .. filename)
end
