local ConvexHull = {}


------- PRIVATE METHODS -------

-- calculate the cross product of vectors (p1p2) and (p1p3)
local function _crossProduct(p1, p2, p3)
  return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
end


------- PUBLIC METHODS -------

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

  -- build the convex hull
  for i = 3, n do
    while #hull >= 2 and _crossProduct(hull[#hull - 1], hull[#hull], points[i]) <= 0 do
      table.remove(hull)
    end
    table.insert(hull, points[i])
  end
  return hull
end

-- Time Complexity: O(n+k)
-- Proposed by Skala in 2016 ("Efficient Algorithms for Convex Hulls of Simple Polygons")
-- Description: It is based on a sweep-line technique and is designed to have a time
-- complexity of O(n+k) in practice for many datasets.
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

  -- Compute the upper hull
  for i = 1, n do
      while #upperHull >= 2 and
          ((upperHull[#upperHull].x - upperHull[#upperHull - 1].x) * (points[i].y - upperHull[#upperHull].y) -
           (upperHull[#upperHull].y - upperHull[#upperHull - 1].y) * (points[i].x - upperHull[#upperHull].x)) <= 0 do
          table.remove(upperHull)
      end
      table.insert(upperHull, points[i])
  end

  -- Compute the lower hull
  for i = n, 1, -1 do
      while #lowerHull >= 2 and
          ((lowerHull[#lowerHull].x - lowerHull[#lowerHull - 1].x) * (points[i].y - lowerHull[#lowerHull].y) -
           (lowerHull[#lowerHull].y - lowerHull[#lowerHull - 1].y) * (points[i].x - lowerHull[#lowerHull].x)) <= 0 do
          table.remove(lowerHull)
      end
      table.insert(lowerHull, points[i])
  end

  -- Remove duplicate points at the start and end of the lower hull
  table.remove(lowerHull, 1)
  table.remove(lowerHull, #lowerHull)

  -- Combine the upper and lower hulls to form the convex hull
  for i = 1, #lowerHull do
      table.insert(upperHull, lowerHull[i])
  end

  return upperHull
end

return ConvexHull
