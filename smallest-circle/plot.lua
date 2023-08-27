-- plot.lua
-- This module provides functions to add plot objects (points, curves, circles)
-- and generate plots using a Python script. It allows data to be saved to a
-- JSON file or passed directly through a pipe to the Python script.

local cjson = require("cjson")
local Plot = {}

-- Global variables for script and JSON filenames
Plot.SCRIPT_NAME = "plot.py"
Plot.JSON_NAME = "plot.json"

Plot.plot_data = {}

function Plot.addPoint(x, y, label)
  table.insert(Plot.plot_data, {
    type = "point",
    x = x,
    y = y,
    label = label
  })
end

function Plot.addCurve(x, y, label)
  table.insert(Plot.plot_data, {
    type = "curve",
    x = x,
    y = y,
    label = label
  })
end

function Plot.addCircle(center_x, center_y, radius, label, color)
  table.insert(Plot.plot_data, {
    type = "circle",
    center = {x = center_x, y = center_y},
    radius = radius,
    label = label,
    color = color,
  })
end

-- Save plot data to a file with default or specified name
function Plot.saveToFile(filename)
  filename = filename or Plot.JSON_NAME
  local json_data = cjson.encode(Plot.plot_data)
  local file = io.open(filename, "w")
  file:write(json_data)
  file:close()
end

function Plot.plot(use_file)
  if use_file then
    -- write to a file and call Python script with file
    Plot.saveToFile()
    local command = 'python "' .. Plot.SCRIPT_NAME .. '" ' .. Plot.JSON_NAME
    os.execute(command)
  else
    -- call Python script through a pipe with JSON data
    local json_data = cjson.encode(Plot.plot_data)
    local pipe = io.popen('python "' .. Plot.SCRIPT_NAME .. '"', 'w')
    pipe:write(json_data)
    pipe:close()
  end
end

return Plot
