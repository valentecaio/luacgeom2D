#!/usr/bin/lua

package.path = package.path .. ";./?/?.lua"
package.path = package.path .. ";../?/?.lua"

local Utils = require("utils")
local Plot = require("matplotlua")


----------- SCRIPT SETUP -----------

local path_in  = arg[1] or "malha.txt"
local path_out = arg[2] or "malha_adj.txt"


----------- AUXILIARY FUNCTIONS -----------


--[[ example:
  mesh = {
    vertices = {
      {x = 0, y = 0), -- coordinates of vertex 1
      {x = 1, y = 0),
      {x = 0, y = 1),
      [...]
    },
    faces = {
      {1, 2, 3}, -- vertices 1, 2 and 3 form a triangle, which is face 1
      {2, 3, 1},
      [...]
    },
  }
]]--
function readMesh(path)
  -- the first line contains the number of vertices (n) and the number of faces (m).
  local lines = Utils.readFile(path)
  local n, m = lines[1]:match("(%d+) (%d+)")

  local mesh = {
    vertices = {},
    faces = {},
  }

  -- the following n lines contain the coordinates of the vertices.
  for i = 2, n+1 do
    local x, y = lines[i]:match("(%d+) (%d+)")
    table.insert(mesh.vertices, {x = tonumber(x), y = tonumber(y)})
  end

  -- the following m lines contain the faces, where each face is a list of 3 vertice indices
  for i = n+2, n+m+1 do
    local a, b, c = lines[i]:match("(%d+) (%d+) (%d+)")
     -- +1 because lua arrays start at 1
    table.insert(mesh.faces, {math.floor(a+1), math.floor(b+1), math.floor(c+1)})
  end
  return mesh
end

-- generate output in the format:
-- the first line contains the number of vertices (n) and the number of faces (m).
-- the following n lines contain the coordinates of the vertices and the id of an adjacent face.
-- the following m lines contain the faces. 
-- each face is a list of 3 vertice indices followed by a list of 3 adjacent face indices.
-- since lua arrays start at 1, we subtract 1 from each index
function writeMesh(path, mesh)
  local lines = {
    #mesh.vertices .. " " .. #mesh.faces,
  }
  for _, v in ipairs(mesh.vertices) do
    table.insert(lines, v.x .. " " .. v.y .. " " .. v.adj_face-1)
  end
  for _,f in ipairs(mesh.faces) do
    -- -1 because lua arrays start at 1
    table.insert(lines, f[1].vertex  -1 .. " " .. f[2].vertex  -1 .. " " .. f[3].vertex  -1
              .. " " .. f[1].opp_face-1 .. " " .. f[2].opp_face-1 .. " " .. f[3].opp_face-1)
  end
  Utils.writeFile(path, lines)
  print("wrote output to " .. path)
end

-- convert face to string for debugging
function faceToString(face)
  return "Face{" .. face[1] .. ", " .. face[2] .. ", " .. face[3] .. "}"
end

function triangleCenter(p1, p2, p3)
  return {
    x = (p1.x + p2.x + p3.x) / 3,
    y = (p1.y + p2.y + p3.y) / 3,
  }
end

function plotMesh(mesh)
  -- vertices of mesh
  Plot.addPointList(mesh.vertices, "black")

  -- edges of mesh
  for _,face in ipairs(mesh.faces) do
    Plot.addPolygon{mesh.vertices[face[1]], mesh.vertices[face[2]], mesh.vertices[face[3]]}
  end
end

function plotDual(mesh)
  local points = {}
  for _,face in ipairs(mesh.faces) do
    -- vertices of dual graph
    table.insert(points, face.center)

    -- edges of dual graph
    for i=1,3 do
      local opp_face = mesh.faces[face[i].opp_face]
      if opp_face then
        Plot.addLine(face.center, opp_face.center, nil, "red")
      end
    end
  end
  Plot.addPointList(points, "red")
end


----------- DUAL GRAPH FUNCTIONS -----------

-- find face that shares two vertices with the current face_id
-- returns 0 if no such face exists
function findOppositeFace(faces, face_id, vid1, vid2)
  for i, face in ipairs(faces) do
    if i ~= face_id and Utils.listIsSubset(face, {vid1, vid2}) then
      return i
    end
  end
  return 0
end

--[[ example:
  mesh = {
    vertices = {
      {x = 0, y = 0, adj_face = 1}, -- x and y are the coordinates of the vertex
      {x = 1, y = 0, adj_face = 2}, -- adj_face is the id of a random adjacent face
      {x = 0, y = 1, adj_face = 2},
      [...]
    },
    faces = {
      {
        center = {x = 0.5, y = 1},  -- coordinates of the baricenter of the face
        {vertex = 1, opp_face = 2}, -- vertex is the id of the vertex in the vertices array
        {vertex = 2, opp_face = 1}, -- opp_face is the id of the opposite face in the faces array
        {vertex = 3, opp_face = 0}, -- or 0 if no opposite face exists
      },
      {
        center = {x = 0.7, y = 0.3},
        {vertex = 2, opp_face = 2},
        {vertex = 3, opp_face = 2},
        {vertex = 1, opp_face = 1},
      },
      [...]
    },
  }
]]--
function createDualGraphMesh(mesh)
  local out = {
    vertices = mesh.vertices,
    faces = {},
  }

  for face_id, face in ipairs(mesh.faces) do
    -- the three vertices of the face are adjacent to the face
    out.vertices[face[1]].adj_face = face_id
    out.vertices[face[2]].adj_face = face_id
    out.vertices[face[3]].adj_face = face_id

    -- for each vertex of a face, we find its opoosite face, which is
    -- the face that shares the other two vertices with the current face
    table.insert(out.faces, {
      {
        vertex = face[1],
        opp_face = findOppositeFace(mesh.faces, face_id, face[2], face[3]),
      },
      {
        vertex = face[2],
        opp_face = findOppositeFace(mesh.faces, face_id, face[1], face[3]),
      },
      {
        vertex = face[3],
        opp_face = findOppositeFace(mesh.faces, face_id, face[1], face[2]),
      },
      center = triangleCenter(
        mesh.vertices[face[1]],
        mesh.vertices[face[2]],
        mesh.vertices[face[3]]
      ),
    })
  end

  return out
end


----------- MAIN -----------

local mesh = readMesh(path_in)
local dual = createDualGraphMesh(mesh)
-- Utils.printTable(dual)

writeMesh(path_out, dual)

plotMesh(mesh)
plotDual(dual)
Plot.plot()

