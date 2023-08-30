local SmallestCircle = {}

------- PUBLIC METHODS -------

function SmallestCircle.dummy(points)
  local minX, maxX, minY, maxY = _findMinMaxCoordinates(points)
  local centerX = (minX + maxX) / 2
  local centerY = (minY + maxY) / 2
  local radius = _eucl_distance(maxX, maxY, minX, minY) / 2
  return centerX, centerY, radius
end

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

  return centerX, centerY, radius
end

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

  return centerX, centerY, radius
end

function SmallestCircle.welzl(points)

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
  local minXIndex, maxXIndex, minYIndex, maxYIndex = _findMinMaxIndexes(points)
  return points[minXIndex].x, points[maxXIndex].x, points[minYIndex].y, points[maxYIndex].y
end

return SmallestCircle
