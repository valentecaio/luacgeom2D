package.path = package.path .. ";" .. arg[0]:match("(.-)[^/]+$") .. "?.lua"

local Plot = require("plot")
local SmallestCircle = require("smallest_circle")

-- Function to generate N random points within a given square
function generateRandomPoints(N, minX, minY, maxX, maxY)
  local points = {}
  for i = 1, N do
    local x = math.random(minX, maxX)
    local y = math.random(minY, maxY)
    table.insert(points, {x = x, y = y})
  end
  
  for _, point in ipairs(points) do
    Plot.addPoint(point.x, point.y)
  end
  
  return points
end

function AddPoints(points)
  for _, point in ipairs(points) do
    Plot.addPoint(point.x, point.y)
  end
end

local points = generateRandomPoints(100, 0, 0, 100, 100)
AddPoints(points)

centerX, centerY, radius = SmallestCircle.dummy(points)
Plot.addCircle(centerX, centerY, radius, "Dummy", "blue")

centerX, centerY, radius = SmallestCircle.bruteForce(points)
Plot.addCircle(centerX, centerY, radius, "Brute Force", "red")

Plot.plot()