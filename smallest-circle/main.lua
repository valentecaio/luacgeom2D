package.path = package.path .. ";" .. arg[0]:match("(.-)[^/]+$") .. "?.lua"

local Plot = require("matplotlua")
local SmallestCircle = require("smallest_circle")

-- generate N random points within a given rectangle
function generateRandomPoints(N, minX, minY, maxX, maxY)
  local points = {}
  for i = 1, N do
    local x = math.random(minX, maxX)
    local y = math.random(minY, maxY)
    table.insert(points, {x = x, y = y})
  end
  return points
end

-- generate N random points contained in a given circle
function generateRandomPointsInCircle(N, centerX, centerY, radius)
  local points = {}
  for i = 1, N do
    local angle = math.random() * 2 * math.pi
    local distance = math.sqrt(math.random()) * radius
    local x = centerX + distance * math.cos(angle)
    local y = centerY + distance * math.sin(angle)
    table.insert(points, {x = x, y = y})
  end
  return points
end

-- add points to the plot
function addPoints(points)
  for _, point in ipairs(points) do
    Plot.addPoint(point.x, point.y)
  end
end

points = generateRandomPointsInCircle(1000, 0, 0, 100)
addPoints(points)

centerX, centerY, radius = SmallestCircle.dummy(points)
Plot.addCircle(centerX, centerY, radius, "Dummy", "red")

centerX, centerY, radius = SmallestCircle.bruteForce(points)
Plot.addCircle(centerX, centerY, radius, "Brute Force", "green")

centerX, centerY, radius = SmallestCircle.heuristic(points)
Plot.addCircle(centerX, centerY, radius, "Heuristic", "blue")

-- Plot.saveToFile()
Plot.plot()
