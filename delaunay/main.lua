#!/usr/bin/lua

package.path = package.path .. ";./?/?.lua"
package.path = package.path .. ";../?/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")
local Delaunay = require("delaunay")

local filepath = arg[1] or "nuvem1.txt"



Plot.init{title = "Delaunay Triangulation"}

-- points
local points = Utils.readPointsFromFile(filepath)
Plot.addPointList(points, "red")

-- super triangle
-- local supra = Delaunay.supratriangle(points)
-- Plot.addPoint(supra.circumcircle.x, supra.circumcircle.y, "green")
-- Plot.addCircle(supra.circumcircle, nil, "green")
-- Plot.addPolygon(supra, nil, "red")
-- Plot.addPointList(supra, "red")

-- delaunay
local mesh = Delaunay.incremental2(points)
for _,t in ipairs(mesh) do
  Plot.addPolygon(t.vertices, nil, "blue")
end

Plot.plot()
