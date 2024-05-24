#!/usr/bin/lua

package.path = package.path .. ";../algorithms/?.lua"
package.path = package.path .. ";../matplotlua/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")
local EnclosingCircle = require("enclosing_circle")
local ConvexHull = require("convex_hull")

local cmds = {"complexity", "compare", "dumb", "heuristic", "bruteforce", "welzl", "smolik"}
local cmds_str = table.concat(cmds, "|")
local function print_help_and_quit()
  print("Usage: lua " .. arg[0] .. " <method> [N] [output_file]\
    N: number of random points in the dataset (optional, default: 100)\
    output: path of the output file (optional, default: do not save any file)\
    method: one of [" .. cmds_str .. "]")
  os.exit()
end

-- validate args
if (not arg[1]) or (not string.find(cmds_str, arg[1])) then
  print_help_and_quit()
end

local N = arg[2] or 100
local base_circle = {x = 0, y = 0, r = 100}
local rand_points = Utils.generateRandomPointsInCircle(N, base_circle)

if arg[1] == "complexity" then
  -- parameters for the analysis
  local min = 100
  local max = 7000
  local step = 10

  -- used to print progress
  local totalIterations = (max - min) / step + 1
  local count = -1

  -- init data to be plotted
  local sizes = {}
  local dumbTimes = {}
  local heuristicTimes = {}
  local bruteforceTimes = {}
  local welzlTimes = {}
  local smolikTimes = {}

  for size = min, max, step do
    local points = Utils.generateRandomPointsInCircle(size, base_circle)
    local dumbTime = Utils.measureExecutionTime(EnclosingCircle.dumb, points)
    local heuristicTime = Utils.measureExecutionTime(EnclosingCircle.heuristic, points)
    -- local bruteforceTime = Utils.measureExecutionTime(EnclosingCircle.bruteForce, points)
    local welzlTime = Utils.measureExecutionTime(EnclosingCircle.welzl, points)
    local smolikTime = Utils.measureExecutionTime(EnclosingCircle.smolik, points)

    table.insert(sizes, size)
    table.insert(dumbTimes, dumbTime)
    table.insert(heuristicTimes, heuristicTime)
    -- table.insert(bruteforceTimes, bruteforceTime)
    table.insert(welzlTimes, welzlTime)
    table.insert(smolikTimes, smolikTime)

    count = count+1
    if count % 10 == 0 then
      print(string.format("Progress: %.1f%%", #sizes / totalIterations * 100))
    end
  end

  Plot.init{title = "Enclosing Circle Execution Time", xlabel = "Number of points", ylabel = "Time (s)"}
  Plot.addCurve(sizes, dumbTimes, "Dumb", "red")
  Plot.addCurve(sizes, heuristicTimes, "Heuristic", "green")
  -- Plot.addCurve(sizes, bruteforceTimes, "Brute Force", "blue")
  Plot.addCurve(sizes, welzlTimes, "Welzl", "blue")
  Plot.addCurve(sizes, smolikTimes, "Smolik", "brown")
  Plot.plot()

elseif arg[1] == "compare" then
  Plot.init{title = "Enclosing Circle Comparison (N = " .. N .. ")", xlabel = "x", ylabel = "y"}
  Plot.addPointList(rand_points)

  local time, circle = Utils.measureExecutionTime(EnclosingCircle.dumb, rand_points)
  print("Dumb:      " .. Utils.tableToString(circle), " in " .. time .. " seconds")
  Plot.addCircle(circle, "Dumb", "red")

  time, circle = Utils.measureExecutionTime(EnclosingCircle.heuristic, rand_points)
  print("Heuristic: " .. Utils.tableToString(circle), " in " .. time .. " seconds")
  Plot.addCircle(circle, "Heuristic", "green")

  time, circle = Utils.measureExecutionTime(EnclosingCircle.welzl, rand_points)
  print("Welzl:     " .. Utils.tableToString(circle), " in " .. time .. " seconds")
  Plot.addCircle(circle, "Welzl", "blue")

  time, circle = Utils.measureExecutionTime(EnclosingCircle.smolik, rand_points)
  print("Smolik:    " .. Utils.tableToString(circle), " in " .. time .. " seconds")
  Plot.addCircle(circle, "Smolik", "brown")

  -- time, circle = Utils.measureExecutionTime(EnclosingCircle.bruteForce, rand_points)
  -- print("Brute Force: " .. Utils.tableToString(circle) .. "in " .. time .. " seconds")
  -- Plot.addCircle(circle, "Brute Force", "blue")

  Plot.plot()
  -- Plot.figure("../figures/enclosing_circle-compare.png")

  
else
  local method
  if arg[1] == "dumb" then
    method = EnclosingCircle.dumb
  elseif arg[1] == "heuristic" then
    method = EnclosingCircle.heuristic
  elseif arg[1] == "bruteforce" then
    method = EnclosingCircle.bruteForce
  elseif arg[1] == "welzl" then
    method = EnclosingCircle.welzl
  elseif arg[1] == "smolik" then
    method = EnclosingCircle.smolik
  else
    print_help_and_quit()
  end

  local time, circle = Utils.measureExecutionTime(method, rand_points)
  print("Found circle: " .. Utils.tableToString(circle))
  print("Execution time: " .. time .. " seconds")
  print("Is this a valid result? " .. tostring(EnclosingCircle.validateCircle(circle, rand_points)))
  Plot.init{title = "Enclosing Circle (method: " .. arg[1] .. ", N: " .. N .. ")"}
  Plot.addPointList(rand_points)
  Plot.addCircle(circle)
  if arg[3] then
    Plot.figure(arg[3])
    print("Saved plot to " .. arg[3])
  else
    Plot.plot()
  end
end
