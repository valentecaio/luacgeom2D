#!/usr/bin/lua

package.path = package.path .. ";../?/?.lua"
local Plot = require("matplotlua")
local Utils = require("utils")
local EnclosingCircle = require("enclosing_circle")
local ConvexHull = require("convex_hull")

local cmds = {"complexity", "compare", "dumb", "heuristic", "bruteforce", "welzl", "smolik"}
local cmds_str = table.concat(cmds, "|")
if (not arg[1]) or (not string.find(cmds_str, arg[1])) then
  print("Usage: lua main.lua [" .. cmds_str .. "]")
  return
end

local base_circle = {x = 0, y = 0, r = 100}
local rand_points = Utils.generateRandomPointsInCircle(100, base_circle)

if arg[1] == "complexity" then
  -- init data to be plotted
  local sizes = {}
  local dumbTimes = {}
  local heuristicTimes = {}
  local bruteforceTimes = {}
  local welzlTimes = {}
  local smolikTimes = {}

  -- parameters for the analysis
  local min = 100
  local max = 1000
  local step = 10

  -- used to print progress
  local totalIterations = (max - min) / step + 1
  local count = -1

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
  Plot.init{title = "Enclosing Circle Comparison", xlabel = "x", ylabel = "y"}
  Plot.addPointList(rand_points)

  local circle = EnclosingCircle.dumb(rand_points)
  print("Dumb:      " .. Utils.tableToString(circle))
  Plot.addCircle(circle, "Dumb", "red")

  circle = EnclosingCircle.heuristic(rand_points)
  print("Heuristic: " .. Utils.tableToString(circle))
  Plot.addCircle(circle, "Heuristic", "green")

  circle = EnclosingCircle.welzl(rand_points)
  print("Welzl:     " .. Utils.tableToString(circle))
  Plot.addCircle(circle, "Welzl", "blue")

  circle = EnclosingCircle.smolik(rand_points)
  print("Smolik:    " .. Utils.tableToString(circle))
  Plot.addCircle(circle, "Smolik", "brown")

  -- circle = EnclosingCircle.bruteForce(rand_points)
  -- print("Brute Force: " .. Utils.tableToString(circle))
  -- Plot.addCircle(circle, "Brute Force", "blue")

  Plot.plot()

else
  local circle = nil
  if arg[1] == "dumb" then
    circle = EnclosingCircle.dumb(rand_points)
    Plot.init{title = "Dumb Enclosing Circle"}

  elseif arg[1] == "heuristic" then
    circle = EnclosingCircle.heuristic(rand_points)
    Plot.init{title = "Heuristic Enclosing Circle"}

  elseif arg[1] == "bruteforce" then
    circle = EnclosingCircle.bruteForce(rand_points)
    Plot.init{title = "Brute Force Enclosing Circle"}

  elseif arg[1] == "welzl" then
    circle = EnclosingCircle.welzl(rand_points)
    Plot.init{title = "Welzl's Enclosing Circle"}

  elseif arg[1] == "smolik" then
    circle = EnclosingCircle.smolik(rand_points)
    Plot.init{title = "Smolik's Enclosing Circle"}
  end

  print("Found circle: " .. Utils.tableToString(circle))
  print("Is this a valid result? " .. tostring(EnclosingCircle.validateCircle(circle, rand_points)))
  Plot.addPointList(rand_points)
  Plot.addCircle(circle)
  Plot.plot()
end
