local Utils = {}

-- deep copy a table recursively
function Utils.deepcopy(orig)
  local orig_type = type(orig)
  local copy

  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[Utils.deepcopy(orig_key)] = Utils.deepcopy(orig_value)
    end
    setmetatable(copy, Utils.deepcopy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end

-- print a table recursively
function Utils.printTable(t, name, indent)
  name = name or ''
  indent = indent or ''
  for k, v in pairs(t) do
    if type(v) == 'table' then
      print(indent .. name .. '.' .. k, v)
      Utils.printTable(v, name .. '.' .. k, indent .. '  ')
    else
      print(indent .. name .. '.' .. k, v)
    end
  end
end

function Utils.tableToString(t)
  local str = '{ '
  for k, v in pairs(t) do
    str = str .. k .. '= ' .. v .. ', '
  end
  return str .. '}'
end

-- shuffle a numeric table in O(n)
function Utils.shuffle(list)
  local n = #list
  for i = n, 2, -1 do
      local j = math.random(i)
      list[i], list[j] = list[j], list[i]
  end
end

-- measure the execution time of a function
function Utils.measureExecutionTime(func, ...)
  local start_time = os.clock()
  ret = func(...)
  local end_time = os.clock()
  return end_time - start_time, ret
end

-- generate N random points contained in a given circle
function Utils.generateRandomPointsInCircle(N, circle)
  -- we need a random seed to avoid generating the same points every time
  math.randomseed(os.clock()*100000000000)

  local points = {}
  for i = 1, N do
    local angle = math.random() * 2 * math.pi
    local distance = math.sqrt(math.random()) * circle.r
    local x = circle.x + distance * math.cos(angle)
    local y = circle.y + distance * math.sin(angle)
    table.insert(points, {x = x, y = y})
  end
  return points
end

function Utils.readPointsFromString(str)
  local points = {}
  for x, y in str:gmatch("(%d+)%s+(%d+)") do
    if x and y then
      table.insert(points, {x = tonumber(x), y = tonumber(y)})
    end
  end
  return points
end

return Utils
