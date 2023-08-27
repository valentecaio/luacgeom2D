package.path = package.path .. ";" .. arg[0]:match("(.-)[^/]+$") .. "?.lua"

local Plot = require("plot")

-- Add plot objects using the new functions
Plot.addPoint({2.5, 3, 1.8, 2.2}, {5.5, 7, 6.2, 6.8})
Plot.addCircle(2, 6, 3)
Plot.addCurve({0, 1, 2, 3, 4, 5}, {1, 3, 5, 7, 9, 11})

-- Plot the generated data using the file
Plot.plot()
