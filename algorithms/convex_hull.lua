package.path = package.path .. ";../matplotlua/?.lua"
package.path = package.path .. ";./?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")

-- we need the following state variables if we want to generate a step-by-step GIF
local ConvexHull = {
  gif = false,      -- set to true before calling a method to generate figures
  hull = {},        -- convex hull points
  points = {},      -- input points
}

------- AUXILIAR -------

-- save a frame of the plot to generate a GIF
local function _setup_plot()
  Plot.clear()
  Plot.addPointList(ConvexHull.points)
  Plot.addPolygon(ConvexHull.hull, "Convex Hull", "green")
  Plot.saveFrame()
end

-- initialize the convex hull with the given points
local function _hull_init(hull)
  ConvexHull.hull = hull
  if ConvexHull.gif then
    _setup_plot()
  end
  return ConvexHull.hull
end

-- append a point to the convex hull
local function _hull_insert(point)
  table.insert(ConvexHull.hull, point)
  if ConvexHull.gif then
    _setup_plot()
  end
end

-- euclidean distance between two points
local function _eucl_distance(p1, p2)
  return math.sqrt((p1.x-p2.x)^2 + (p1.y-p2.y)^2)
end

-- calculate the cross product of vectors (p1p2) and (p1p3)
-- returns > 0 if p1, p2, p3 are in counter-clockwise order
-- returns < 0 if p1, p2, p3 are in clockwise order
-- returns 0 when p1, p2, p3 are collinear
local function _orient(p1, p2, p3)
  return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
end


------- ALGORITHMS -------

-- Time Complexity: O(nh), where "h" is the number of vertices on the convex hull.
-- Proposed by R.A. Jarvis in 1973.
-- Description: Jarvis March, or the Gift Wrapping algorithm, iteratively selects
-- the point with the smallest polar angle as the next vertex of the convex hull.
function ConvexHull.jarvisMarch(points)
  ConvexHull.points = points

  -- if there are less than 3 points, they are the hull
  if #points <= 2 then
    return _hull_init(points)
  end

  -- find the point with the lowest y-coordinate (and leftmost if tied)
  local pivot = points[1]
  for i = 2, #points do
    if points[i].y < pivot.y or (points[i].y == pivot.y and points[i].x < pivot.x) then
      pivot = points[i]
    end
  end

  -- sort the points based on polar angle from the pivot
  table.sort(points, function(p1, p2)
    local orient = _orient(pivot, p1, p2)
    if orient == 0 then
      -- if the points are collinear, the closest point to the pivot comes first
      return _eucl_distance(pivot, p1) < _eucl_distance(pivot, p2)
    end
    return orient > 0
  end)

  -- initialize the convex hull with the pivot and the first two sorted points
  local hull = _hull_init{pivot, points[1], points[2]}

  -- build the convex hull
  for i = 3, #points do
    -- remove points that would create clockwise turns
    while #hull >= 2 and _orient(hull[#hull-1], hull[#hull], points[i]) <= 0 do
      table.remove(hull)
    end
    _hull_insert(points[i])
  end

  return hull
end

-- Time Complexity: O(n+h)
-- Proposed by Skala in 2016 ("Efficient Algorithms for Convex Hulls of Simple Polygons")
-- Description: It is based on a sweep-line technique and is designed to have a time
-- complexity of O(n) in practice for many datasets.
function ConvexHull.skala(points)
  ConvexHull.points = points

  -- if there are less than 3 points, they are the hull
  if #points <= 2 then
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
  for i = 1, #points do
    -- remove points that would create clockwise turns
    while #upperHull >= 2 and _orient(upperHull[#upperHull-1], upperHull[#upperHull], points[i]) <= 0 do
      table.remove(upperHull)
    end
    table.insert(upperHull, points[i])
    if ConvexHull.gif then
      table.insert(steps, Utils.deepcopy(upperHull))
    end
  end

  -- Compute the lower hull
  for i = #points, 1, -1 do
    -- remove points that would create clockwise turns
    while(#lowerHull >= 2 and _orient(lowerHull[#lowerHull-1], lowerHull[#lowerHull], points[i]) <= 0) do
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
    for _,hull in ipairs(steps) do
      ConvexHull.hull = hull
      _setup_plot()
    end
  end
  return upperHull
end

return ConvexHull
