
Utils = require "utils"

local Delaunay = {}


-------- DEBUG --------

local function debug_print(...)
  if DEBUG then
    print(...)
  end
end

local function _plotstate(p, triangles, points, bad_triangles, polygon, new_triangles)
  local Plot = require "matplotlua"
  Plot.init{title = "Delaunay Triangulation State"}

  Plot.addPointList(points, "blue")
  for _,t in ipairs(triangles) do
    Plot.addPolygon(t.vertices, nil, "blue")
  end

  Plot.addPoint(p.x, p.y, "red")
  -- Plot.addPolygon(polygon, nil, "red")
  for _,t in ipairs(new_triangles) do
    Plot.addPolygon(t.vertices, nil, "red")
  end

  for _,bad_t in ipairs(bad_triangles) do
    -- Plot.addCircle(bad_t.triangle.circumcircle, nil, "green")
  end
  Plot.plot()
end


-------- AUXILIAR --------

-- given 3 points, return the circumcircle of the triangle they form
local function _circumcircle(p1, p2, p3)
  local A = p2.x - p1.x
  local B = p2.y - p1.y
  local C = p3.x - p1.x
  local D = p3.y - p1.y
  local E = A * (p1.x + p2.x) + B * (p1.y + p2.y)
  local F = C * (p1.x + p3.x) + D * (p1.y + p3.y)
  local G = 2 * (A * (p3.y - p2.y) - B * (p3.x - p2.x))

  local x, y
  if math.abs(G) < 0.000001 then
    -- points are co-linear
    x = ((p1.x + p3.x) - (p1.x + p2.x)) / 2
    y = ((p1.y + p3.y) - (p1.y + p2.y)) / 2
  else
    x = (D * E - B * F) / G
    y = (A * F - C * E) / G
  end

  return {x = x, y = y, r = math.sqrt((p1.x - x)^2 + (p1.y - y)^2)}
end

-- given a point and a triangle, checks if the point is inside the circumcircle of the triangle
local function _incircle(p, t)
  return ((p.x - t.circumcircle.x)^2 + (p.y - t.circumcircle.y)^2) <= t.circumcircle.r^2
end

-- calculate the cross product of vectors (p1p2) and (p1p3)
-- returns > 0 if p1, p2, p3 are in counter-clockwise order
-- returns < 0 if p1, p2, p3 are in clockwise order
-- returns 0 when p1, p2, p3 are collinear
local function _orient(p1, p2, p3)
  return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
end

-- returns true if the point is inside the triangle, using the orientation test
local function _intriangle(p, t)
  local d1 = _orient(p, t[1], t[2])
  local d2 = _orient(p, t[2], t[3])
  local d3 = _orient(p, t[3], t[1])
  return (d1 > 0 and d2 > 0 and d3 > 0) or (d1 < 0 and d2 < 0 and d3 < 0)
end



-- given a list of points, returns a supertriangle that contains all points
local function SupraTriangle(points)
  local xmin, ymin, xmax, ymax = math.huge, math.huge, -math.huge, -math.huge
  for _, p in ipairs(points) do
    xmin, ymin = math.min(xmin, p.x), math.min(ymin, p.y)
    xmax, ymax = math.max(xmax, p.x), math.max(ymax, p.y)
  end

  -- center
  local cx = (xmin + xmax) / 2
  local cy = (ymin + ymax) / 2

  -- M is the maximum distance from center to a corner
  local M = (xmax-xmin > ymax-ymin) and xmax-cx or ymax-cy

  return Delaunay.Triangle(
    {x = cx,     y = cy+3*M}, -- top
    {x = cx-3*M, y = cy-3*M}, -- left    
    {x = cx+3*M, y = cy}      -- right
  )
end

-- compare two edges
local function edge_equal(e1, e2)
  return (e1[1] == e2[1] and e1[2] == e2[2]) or (e1[1] == e2[2] and e1[2] == e2[1])
end

-- check if two triangles share an edge
local function triangle_share_edge(t1, t2)
  for _, e1 in ipairs(t1.edges) do
    for _, e2 in ipairs(t2.edges) do
      if edge_equal(e1, e2) then
        return true
      end
    end
  end
  return false
end

-- check if an edge of a triangle is shared by any other triangle, skip_index is the index of the triangle of the edge
local function bad_edge(e, bad_triangles, skip_index)
  for _, t in ipairs(bad_triangles) do
    if t.index ~= skip_index and Utils.listIsSubset(t.triangle.vertices, e) then
      return true
    end
  end
  return false
end


------ ALGORITHMS ------


-------- DATA STRUCTURES --------

function Delaunay.Triangle(p1, p2, p3)
  return {
    vertices = {p1, p2, p3},
    circumcircle = _circumcircle(p1, p2, p3),
    edges = {
      {p1, p2},
      {p2, p3},
      {p3, p1},
    },
  }
end

-- Bowyer-Watson algorithm
function Delaunay.incremental2(points)
  local supra = SupraTriangle(points)
  local triangles = {supra}

  for pi,p in ipairs(points) do
    debug_print("-------------------------- " .. pi .. " --------------------------")
    -- find all triangles that are no longer valid due to the insertion
    local bad_triangles = {}
    for ti, t in ipairs(triangles) do
      if _incircle(p, t) then
        table.insert(bad_triangles, {index = ti, triangle = t})
      end
    end
    debug_print("#bad_triangles = "..#bad_triangles)

    -- remove bad triangles from the triangles list
    for i=#bad_triangles,1,-1 do
      table.remove(triangles, bad_triangles[i].index)
      debug_print("removed triangle, #triangles = "..#triangles)
    end

    -- find the polygonal hole left by the bad triangles
    local polygon = {} -- list of edges
    for _, bad_t in ipairs(bad_triangles) do
      for _, e in ipairs(bad_t.triangle.edges) do
        if not bad_edge(e, bad_triangles, bad_t.index) then
          table.insert(polygon, e)
        end
      end
    end
    debug_print("#polygon = "..#polygon)

    -- re-triangulate the polygonal hole
    local new_triangles = {}
    for _, e in ipairs(polygon) do
      local t = Delaunay.Triangle(p, e[1], e[2])
      table.insert(new_triangles, t)
      table.insert(triangles, t)
    end
    debug_print("#new_triangles = "..#new_triangles)
    debug_print("#triangles = "..#triangles)

    _plotstate(p, triangles, points, bad_triangles, polygon, new_triangles)
  end

  -- remove all triangles that contain a vertex of the supertriangle
  for i=#triangles,1,-1 do
    for _, v in ipairs(supra.vertices) do
      if Utils.listContains(triangles[i].vertices, v) then
        table.remove(triangles, i)
        break
      end
    end
  end
  return triangles
end




return Delaunay
