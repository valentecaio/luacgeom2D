-- This module provides functions to add plot objects (points, curves, circles)
-- and generate plots using a Python script. It allows data to be saved to a
-- JSON file or passed directly through a pipe to the Python script.

local cjson = require("cjson")
local Plot = {}

-- we want to call the Python script locally from the same directory
local lib_dir = debug.getinfo(1, 'S').source:match[[^@?(.*[\/])[^\/]-$]]

-- global variables for script and JSON filenames
Plot.SCRIPT_PATH = lib_dir .. "matplotlua.py"
Plot.JSON_NAME = "matplotlua.json"

function Plot.clear()
  Plot.state = {
    points = {},
    curves = {},
    circles = {},
    polygons = {},
  }
end

-- reset plot data and merge with new data
function Plot.init(data)
  Plot.clear()
  for k,v in pairs(data) do Plot.state[k] = v end
end

-- points is a list of tables with x and y coordinates
function Plot.addPointList(points)
  for _, p in ipairs(points) do
    table.insert(Plot.state.points, {
      x = p.x,
      y = p.y,
    })
  end
end

-- x and y can be numbers or lists of numbers
function Plot.addPoint(x, y)
  table.insert(Plot.state.points, {
    x = x,
    y = y,
  })
end

-- x and y are lists of vertices in the curve
function Plot.addCurve(x, y, label)
  table.insert(Plot.state.curves, {
    x = x,
    y = y,
    label = label
  })
end

-- circle is a table with x, y (for the center) and r(adius)
function Plot.addCircle(circle, label, color)
  table.insert(Plot.state.circles, {
    center = {x = circle.x, y = circle.y},
    radius = circle.y,
    label = label,
    color = color,
  })
end

function Plot.addPolygon(points, label, color)
  local vertices = {}
  for _, point in ipairs(points) do
    table.insert(vertices, {point.x, point.y})
  end
  table.insert(Plot.state.polygons, {
    vertices = vertices,
    label = label,
    color = color,
  })
end

-- dump plot data to a file with default or specified name
function Plot.saveToFile(filename)
  filename = filename or Plot.JSON_NAME
  local json_data = cjson.encode(Plot.state)
  local file = io.open(filename, "w")
  file:write(json_data)
  file:close()
end

function Plot.plot(use_file)
  if use_file then
    -- write to a file and call Python script with file
    Plot.saveToFile()
    local command = 'python "' .. Plot.SCRIPT_PATH .. '" ' .. Plot.JSON_NAME
    os.execute(command)
  else
    -- call Python script through a pipe with JSON data
    local json_data = cjson.encode(Plot.state)
    local pipe = io.popen('python "' .. Plot.SCRIPT_PATH .. '"', 'w')
    pipe:write(json_data)
    pipe:close()
  end
end

-- init Plot.state
Plot.clear()

return Plot
