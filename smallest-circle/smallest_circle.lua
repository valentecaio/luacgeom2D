package.path = package.path .. ";../?/?.lua"
local Utils = require("utils")

local SmallestCircle = {}

------- PUBLIC METHODS -------

-- dummiest way to find any circle containing all the points
-- the returned circle contains the rectangle containing all the points
function SmallestCircle.dummy(points)
  local minX, maxX, minY, maxY = _findMinMaxCoordinates(points)
  local centerX = (minX + maxX) / 2
  local centerY = (minY + maxY) / 2
  local radius = _eucl_distance(maxX, maxY, minX, minY) / 2
  return {x = centerX, y = centerY, r = radius}
end

-- dummiest way to find the smallest circle containing all the points
-- should be O(n^4)
function SmallestCircle.bruteForce(points)
  local minX, maxX, minY, maxY = _findMinMaxCoordinates(points)
  local centerX, centerY, radius = 0, 0, math.huge

  for x = minX, maxX do
    for y = minY, maxY do
      local maxDist = 0
      for _, point in ipairs(points) do
        maxDist = math.max(maxDist, _eucl_distance(x, y, point.x, point.y))
      end
      if maxDist < radius then
        centerX, centerY, radius = x, y, maxDist
      end
    end
  end

  return {x = centerX, y = centerY, r = radius}
end

-- heuristic method to find any circle containing all the points
-- the returned circle is not necessarily the smallest, but a good O(n) approximation
function SmallestCircle.heuristic(points)
  local minXIndex, maxXIndex = _findMinMaxIndexes(points)
  local minXPoint, maxXPoint = points[minXIndex], points[maxXIndex]
  local centerX = (minXPoint.x + maxXPoint.x) / 2
  local centerY = (minXPoint.y + maxXPoint.y) / 2
  local radius = _eucl_distance(maxXPoint.x, maxXPoint.y, minXPoint.x, minXPoint.y) / 2

  for _, point in ipairs(points) do
    local distance = _eucl_distance(centerX, centerY, point.x, point.y)
    if distance > radius then
      local newRadius = (radius + distance) / 2
      local ratio = (newRadius - radius) / distance
      centerX = centerX + (point.x - centerX) * ratio
      centerY = centerY + (point.y - centerY) * ratio
      radius = newRadius
    end
  end

  return {x = centerX, y = centerY, r = radius}
end

-- Welzl's algorithm to find the smallest circle containing all the points
-- should be O(n) on average, but O(n^4) in the worst case
function SmallestCircle.welzl(points, n, boundary)
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
  local circle = SmallestCircle.welzl(points, n-1, Utils.deepcopy(boundary))

  -- if the point is inside the circle, return the circle
  -- otherwise, the point must be on the boundary of the circle
  if _eucl_distance(circle.x, circle.y, point.x, point.y) <= circle.r then
    return circle
  else
    table.insert(boundary, point)
    -- Utils.printTable(boundary, "boundary", "  ")
    -- TODO: check why we dont need to deepcopy here (?)
    return SmallestCircle.welzl(points, n-1, boundary)
  end
end

------- PRIVATE METHODS -------

function _eucl_distance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- returns the indexes of minX, maxX, minY and maxY
function _findMinMaxIndexes(points)
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
function _findMinMaxCoordinates(points)
  local minXid, maxXid, minYid, maxYid = _findMinMaxIndexes(points)
  return points[minXid].x, points[maxXid].x, points[minYid].y, points[maxYid].y
end

-- returns a circle containing all the points in the boundary
-- the circle is the smallest circle containing the points in the boundary
-- it is assumed that the boundary is a set of 0, 1, 2 or 3 points
function _makeCircle(boundary)
  assert(#boundary <= 3)
  local p1, p2, p3 = boundary[1], boundary[2], boundary[3]
  if #boundary == 0 then
    return {x = 0, y = 0, r = 0}
  elseif #boundary == 1 then
    return {x = p1.x, y = p1.y, r = 0}
  elseif #boundary == 2 then
    -- if there are just two points in the boundary, the circle containing
    -- them is the circle with the segment between them as diameter
    local radius = _eucl_distance(p1.x, p1.y, p2.x, p2.y) / 2
    return {x = (p1.x+p2.x)/2, y = (p1.y+p2.y)/2, r = radius}
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
    local radius = _eucl_distance(centerX, centerY, x1, y1)
    return {x = centerX, y = centerY, r = radius}
  end
end

return SmallestCircle
