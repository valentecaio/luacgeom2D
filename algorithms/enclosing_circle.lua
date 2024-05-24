package.path = package.path .. ";./?.lua" -- include own dir in package path

local Utils = require("utils")
local ConvexHull = require("convex_hull")

local EnclosingCircle = {}


------- AUXILIARY FUNCTIONS -------

-- returns the euclidean distance between two points
local function _eucl_distance(p1, p2)
  return math.sqrt((p1.x-p2.x)^2 + (p1.y-p2.y)^2)
end

-- returns the indexes of minX, maxX, minY and maxY
local function _findMinMaxIndexes(points)
  local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
  local minXIndex, maxXIndex, minYIndex, maxYIndex = 0, 0, 0, 0

  for i, point in ipairs(points) do
    if point.x < minX then
      minX, minXIndex = point.x, i
    end
    if point.x > maxX then
      maxX, maxXIndex = point.x, i
    end
    if point.y < minY then
      minY, minYIndex = point.y, i
    end
    if point.y > maxY then
      maxY, maxYIndex = point.y, i
    end
  end

  return minXIndex, maxXIndex, minYIndex, maxYIndex
end

-- returns the coordinates of minX, maxX, minY and maxY
local function _findMinMaxCoordinates(points)
  local minXid, maxXid, minYid, maxYid = _findMinMaxIndexes(points)
  return points[minXid].x, points[maxXid].x, points[minYid].y, points[maxYid].y
end

-- returns a circle containing all the points in the boundary
-- the circle is the smallest circle containing the points in the boundary
-- it is assumed that the boundary is a set of 0 to 3 points
local function _makeCircle(boundary)
  assert(#boundary <= 3)
  local p1, p2, p3 = boundary[1], boundary[2], boundary[3]
  if #boundary == 0 then
    return {x = 0, y = 0, r = 0}
  elseif #boundary == 1 then
    return {x = p1.x, y = p1.y, r = 0}
  elseif #boundary == 2 then
    -- if there are just two points in the boundary, the circle containing
    -- them is the circle with the segment between them as diameter
    return {
      x = (p1.x + p2.x) / 2,
      y = (p1.y + p2.y) / 2,
      r = _eucl_distance(p1, p2) / 2
    }
  else
    -- find the center of the circle by solving the system of equations:
    -- (x - x1)^2 + (y - y1)^2 = r^2
    -- (x - x2)^2 + (y - y2)^2 = r^2
    -- (x - x3)^2 + (y - y3)^2 = r^2
    -- the solution is the intersection of the three perpendicular bisectors
    local x1, y1, x2, y2, x3, y3 = p1.x, p1.y, p2.x, p2.y, p3.x, p3.y
    local A = 2 * (x2 - x1)
    local B = 2 * (y2 - y1)
    local C = x2^2 + y2^2 - x1^2 - y1^2
    local D = 2 * (x3 - x2)
    local E = 2 * (y3 - y2)
    local F = x3^2 + y3^2 - x2^2 - y2^2
    local centerX = (C*E - F*B) / (E*A - B*D)
    local centerY = (C*D - A*F) / (B*D - A*E)
    local radius = _eucl_distance({x=centerX, y=centerY}, p1)
    return {x = centerX, y = centerY, r = radius}
  end
end

------- ALGORITHMS -------

-- dumbest way to find any enclosing circle
-- the returned circle encloses the rectangle containing all the points
function EnclosingCircle.dumb(points)
  local minX, maxX, minY, maxY = _findMinMaxCoordinates(points)
  return _makeCircle({{x = minX, y = minY}, {x = maxX, y = maxY}})
end

-- dumbest way to find the smallest enclosing circle
-- should be O(n^4)
function EnclosingCircle.bruteForce(points)
  local minX, maxX, minY, maxY = _findMinMaxCoordinates(points)
  local centerX, centerY, radius = 0, 0, math.huge

  for x = minX, maxX do
    for y = minY, maxY do
      local maxDist = 0
      for _, point in ipairs(points) do
        maxDist = math.max(maxDist, _eucl_distance({x=x, y=y}, point))
      end
      if maxDist < radius then
        centerX, centerY, radius = x, y, maxDist
      end
    end
  end

  return {x = centerX, y = centerY, r = radius}
end

-- heuristic method to find any enclosing circle in O(n)
-- the returned circle is not necessarily the smallest, but a good approximation
function EnclosingCircle.heuristic(points)
  local minXid, maxXid, minYid, maxYid = _findMinMaxIndexes(points)
  local distX = _eucl_distance(points[minXid], points[maxXid])
  local distY = _eucl_distance(points[minYid], points[maxYid])
  local circle
  if distY > distX then
    circle = _makeCircle({points[minYid], points[maxYid]})
  else
    circle = _makeCircle({points[minXid], points[maxXid]})
  end

  for _, point in ipairs(points) do
    local distance = _eucl_distance(circle, point)
    if distance > circle.r then
      local newRadius = (circle.r + distance) / 2
      local ratio = (newRadius - circle.r) / distance
      circle.x = circle.x + (point.x - circle.x) * ratio
      circle.y = circle.y + (point.y - circle.y) * ratio
      circle.r = newRadius
    end
  end

  return circle
end

-- Welzl's algorithm to find the smallest enclosing circle
-- should be O(n) on average, but O(n^4) in the worst case
function EnclosingCircle.welzl(points, n, boundary)
  -- default values for the first call
  boundary = boundary or {}
  n = n or #points

  -- base case: if there are no points or 3 points in the boundary,
  -- return the smallest circle enclosing the boundary
  if n == 0 or #boundary == 3 then
    return _makeCircle(boundary)
  end

  -- pick the last point from the set. Now the set length is n-1
  local point = points[n]
  local circle = EnclosingCircle.welzl(points, n-1, Utils.deepcopy(boundary))

  -- if the point is inside the circle, return the circle
  -- otherwise, the point must be on the boundary of the circle
  if _eucl_distance(circle, point) <= circle.r then
    return circle
  else
    table.insert(boundary, point)
    -- Utils.printTable(boundary, "boundary", "  ")
    -- TODO: check why we dont need to deepcopy here (?)
    return EnclosingCircle.welzl(points, n-1, boundary)
  end
end

-- Smolik's algorithm to find the smallest enclosing circle
-- based on the paper "Efficient Speed-Up of the Smallest Enclosing Circle Algorithm"
-- available at https://informatica.vu.lt/journal/INFORMATICA/article/1251
function EnclosingCircle.smolik(points)
  local convex_hull = ConvexHull.skala(points)
  Utils.shuffle(convex_hull)
  return EnclosingCircle.welzl(convex_hull)
end

-- "brute force" check if a circle encloses a given set of points
function EnclosingCircle.validateCircle(circle, points)
  for _, point in ipairs(points) do
    if _eucl_distance(circle, point) > circle.r then
      return false
    end
  end
  return true
end


return EnclosingCircle
