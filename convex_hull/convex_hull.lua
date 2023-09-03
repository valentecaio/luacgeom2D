local ConvexHull = {}

-- calculate the cross product of vectors (p1p2) and (p1p3)
local function crossProduct(p1, p2, p3)
  return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
end

-- find the convex hull of a set of points
function ConvexHull.convexHull(points)
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
    local cross = crossProduct(minYPoint, p1, p2)
    if cross == 0 then
      return (p1.x - minYPoint.x)^2 + (p1.y - minYPoint.y)^2 < (p2.x - minYPoint.x)^2 + (p2.y - minYPoint.y)^2
    end
    return cross > 0
  end)

  -- initialize the convex hull with minYPoint and the first two sorted points
  local hull = {minYPoint, points[1], points[2]}

  -- build the convex hull
  for i = 3, n do
    while #hull >= 2 and crossProduct(hull[#hull - 1], hull[#hull], points[i]) <= 0 do
      table.remove(hull)
    end
    table.insert(hull, points[i])
  end
  return hull
end

return ConvexHull
