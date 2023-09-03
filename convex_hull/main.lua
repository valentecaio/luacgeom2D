package.path = package.path .. ";../?/?.lua"

local ConvexHull = require("convex_hull")
local Plot = require("matplotlua")

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

points = generateRandomPointsInCircle(40, 0, 0, 100)
addPoints(points)

convexHullPoints = ConvexHull.convexHull(points)
Plot.addPolygon(convexHullPoints, "Convex Hull", "red")

Plot.plot()
