#!/usr/bin/lua

-- this file is just an example of how to use the library

package.path = package.path .. ";" .. arg[0]:match("(.-)[^/]+$") .. "?.lua"

local Plot = require("matplotlua")

-- Add plot objects using the new functions
Plot.addPoint({2.5, 3, 1.8, 2.2}, {5.5, 7, 6.2, 6.8})
Plot.addCircle({x=2, y=6, r=3}, 'circle', 'red')
Plot.addCurve({0, 1, 2, 3, 3, 2}, {1, 3, 5, 7, 9, 11}, 'curve', 'green')

-- use this to save to a json file and plot
-- Plot.plot(true)

-- use this to plot directly
Plot.plot()
