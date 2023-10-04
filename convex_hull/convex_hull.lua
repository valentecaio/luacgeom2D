local Plot = require("matplotlua")
local Utils = require("utils")

local ConvexHull = {}

ConvexHull.gif = false      -- set to true before calling a method to generate figures
ConvexHull.dir = "figures/" -- directory to save figures to


------- PRIVATE -------

-- calculate the cross product of vectors (p1p2) and (p1p3)
local function _crossProduct(p1, p2, p3)
  return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
end

local function _plotHull(title, points, hull, i)
  Plot.clear()
  Plot.init{title = title .. " (t = " .. i .. ")"}
  Plot.addPointList(points)
  Plot.addPolygon(hull, "Convex Hull", "green")
  Plot.figure(ConvexHull.dir .. i .. ".png")
end

local function _plotHulls(title, points, hulls)
  _plotHull(title, points, hulls[1], 0, dir)
  for i = 1, #hulls do
    _plotHull(title, points, hulls[i], i, dir)
  end
  _plotHull(title, points, hulls[#hulls], #hulls+1, dir)
  _plotHull(title, points, hulls[#hulls], #hulls+2, dir)
  _plotHull(title, points, hulls[#hulls], #hulls+3, dir)
end


------- PUBLIC -------

-- Time Complexity: O(nh), where "h" is the number of vertices on the convex hull.
-- Proposed by R.A. Jarvis in 1973.
-- Description: Jarvis March, or the Gift Wrapping algorithm, iteratively selects
-- the point with the smallest polar angle as the next vertex of the convex hull.
function ConvexHull.jarvisMarch(points)
  local n = #points

  -- if there are less than 3 points, they are all on the hull
  if n <= 2 then
    return points
  end

  -- find the point with the lowest y-coordinate (and leftmost if tied)
  local minYPoint = points[1]
  for i = 2, n do
    if points[i].y < minYPoint.y or (points[i].y == minYPoint.y and points[i].x < minYPoint.x) then
      minYPoint = points[i]
    end
  end

  -- sort the points based on polar angle from minYPoint
  table.sort(points, function(p1, p2)
    local cross = _crossProduct(minYPoint, p1, p2)
    if cross == 0 then
      return (p1.x - minYPoint.x)^2 + (p1.y - minYPoint.y)^2 < (p2.x - minYPoint.x)^2 + (p2.y - minYPoint.y)^2
    end
    return cross > 0
  end)

  -- initialize the convex hull with minYPoint and the first two sorted points
  local hull = {minYPoint, points[1], points[2]}

  -- for plotting figures
  local steps = {}
  if ConvexHull.gif then
    steps = {Utils.deepcopy(hull)}
  end

  -- build the convex hull
  for i = 3, n do
    while #hull >= 2 and _crossProduct(hull[#hull - 1], hull[#hull], points[i]) <= 0 do
      table.remove(hull)
    end
    table.insert(hull, points[i])
    if ConvexHull.gif then
      table.insert(steps, Utils.deepcopy(hull))
    end
  end

  if ConvexHull.gif then
    _plotHulls("Jarvis Gift Wrapping Convex Hull", points, steps)
  end
  return hull
end

-- Time Complexity: O(n+h)
-- Proposed by Skala in 2016 ("Efficient Algorithms for Convex Hulls of Simple Polygons")
-- Description: It is based on a sweep-line technique and is designed to have a time
-- complexity of O(n) in practice for many datasets.
function ConvexHull.skala(points)
  local n = #points
  if n <= 2 then
    -- No need to compute the convex hull for less than 3 points
    return points
  end

  -- Sort the points lexicographically (first by x, then by y)
  table.sort(points, function(p1, p2)
    if p1.x == p2.x then
      return p1.y < p2.y
    end
    return p1.x < p2.x
  end)

  -- Initialize the upper and lower hulls
  local upperHull = {}
  local lowerHull = {}

  -- for plotting figures
  local steps = {}

  -- Compute the upper hull
  for i = 1, n do
    while #upperHull >= 2 and
      ((upperHull[#upperHull].x - upperHull[#upperHull - 1].x) * (points[i].y - upperHull[#upperHull].y) -
        (upperHull[#upperHull].y - upperHull[#upperHull - 1].y) * (points[i].x - upperHull[#upperHull].x)) <= 0 do
      table.remove(upperHull)
    end
    table.insert(upperHull, points[i])
    if ConvexHull.gif then
      table.insert(steps, Utils.deepcopy(upperHull))
    end
  end

  -- Compute the lower hull
  for i = n, 1, -1 do
    while #lowerHull >= 2 and
      ((lowerHull[#lowerHull].x - lowerHull[#lowerHull - 1].x) * (points[i].y - lowerHull[#lowerHull].y) -
        (lowerHull[#lowerHull].y - lowerHull[#lowerHull - 1].y) * (points[i].x - lowerHull[#lowerHull].x)) <= 0 do
      table.remove(lowerHull)
    end
    table.insert(lowerHull, points[i])
    if ConvexHull.gif then
      table.insert(steps, Utils.deepcopy(lowerHull))
    end
  end

  -- Remove duplicate points at the start and end of the lower hull
  table.remove(lowerHull, 1)
  table.remove(lowerHull, #lowerHull)

  -- Combine the upper and lower hulls to form the convex hull
  for i = 1, #lowerHull do
    table.insert(upperHull, lowerHull[i])
    if ConvexHull.gif then
      table.insert(steps, Utils.deepcopy(upperHull))
    end
  end

  if ConvexHull.gif then
    _plotHulls("Skala Convex Hull", points, steps)
  end
  return upperHull
end

return ConvexHull
