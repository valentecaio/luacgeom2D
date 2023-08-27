local SmallestCircle = {}

function findMinMaxCoordinates(points)
  local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge

  for _, point in ipairs(points) do
    minX = math.min(minX, point.x)
    maxX = math.max(maxX, point.x)
    minY = math.min(minY, point.y)
    maxY = math.max(maxY, point.y)
  end

  return minX, maxX, minY, maxY
end

function SmallestCircle.dummy(points)
  local minX, maxX, minY, maxY = findMinMaxCoordinates(points)
  local centerX = (minX + maxX) / 2
  local centerY = (minY + maxY) / 2
  local radius = math.sqrt((maxX - minX)^2 + (maxY - minY)^2) / 2
  return centerX, centerY, radius
end

function SmallestCircle.bruteForce(points)
  local minX, maxX, minY, maxY = findMinMaxCoordinates(points)
  local centerX, centerY, radius = 0, 0, math.huge

  for x = minX, maxX do
    for y = minY, maxY do
      local maxDistance = 0
      for _, point in ipairs(points) do
        local distance = math.sqrt((x - point.x)^2 + (y - point.y)^2)
        maxDistance = math.max(maxDistance, distance)
      end
      if maxDistance < radius then
        centerX, centerY, radius = x, y, maxDistance
      end
    end
  end

  return centerX, centerY, radius
end

return SmallestCircle