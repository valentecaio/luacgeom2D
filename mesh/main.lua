#!/usr/bin/lua

package.path = package.path .. ";./?/?.lua"
package.path = package.path .. ";../?/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")


----------- AUXILIARY FUNCTIONS -----------

-- the first line contains the number of vertices (n) and the number of faces (m).
-- the following n lines contain the coordinates of the vertices.
-- the following m lines contain the faces, where each face is a list of 3 vertice indices
-- since lua arrays start at 1, we add 1 to each index
function parseInput(path)
  local lines = Utils.readFile(path)
  local n, m = lines[1]:match("(%d+) (%d+)")
  local vertices = {}
  local faces = {}
  for i = 2, n+1 do
    local x, y = lines[i]:match("(%d+) (%d+)")
    table.insert(vertices, {x = x, y = y})
  end
  for i = n+2, n+m+1 do
    local a, b, c = lines[i]:match("(%d+) (%d+) (%d+)")
     -- +1 because lua arrays start at 1
    table.insert(faces, {math.floor(a+1), math.floor(b+1), math.floor(c+1)})
  end
  return {
    vertices = vertices,
    faces = faces,
  }
end

-- generate output in the format:
-- the first line contains the number of vertices (n) and the number of faces (m).
-- the following n lines contain the coordinates of the vertices and the id of an adjacent face.
-- the following m lines contain the faces. 
-- each face is a list of 3 vertice indices followed by a list of 3 adjacent face indices.
-- since lua arrays start at 1, we subtract 1 from each index
function writeOutput(path, mesh)
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
end

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

function findAdjacentFace(faces, vertex_id)
  for i, face in ipairs(faces) do
    -- print("checking if vertex " .. vertex_id .. " appears in face " ..faceToString(face))
    if Utils.listContains(face, vertex_id) then
      return i
    end
  end
end

-- convert face to string for debugging
function faceToString(face)
  return "Face{" .. face[1] .. ", " .. face[2] .. ", " .. face[3] .. "}"
end


----------- DUAL GRAPH FUNCTIONS -----------

--[[ example:
  mesh = {
    vertices = {
      {x = 0, y = 0, adj_face = 1}, -- x and y are the coordinates of the vertex
      {x = 1, y = 0, adj_face = 2}, -- adj_face is the id of a random adjacent face
      {x = 0, y = 1, adj_face = 2},
    },
    faces = {
      {
        {vertex = 1, opp_face = 2}, -- vertex is the id of the vertex in the vertices array
        {vertex = 2, opp_face = 1}, -- opp_face is the id of the opposite face in the faces array
        {vertex = 3, opp_face = 0}, -- or 0 if no opposite face exists
      },
      {
        {vertex = 2, opp_face = 2},
        {vertex = 3, opp_face = 2},
        {vertex = 1, opp_face = 1},
      },
    },
  }
]]--
function createDualGraphMesh(vertices, faces)
  local mesh = {
    vertices = {},
    faces = {},
  }

  -- VERTICES: for each vertex, find ANY adjacent face
  for i, vertex in ipairs(vertices) do
    table.insert(mesh.vertices, {
      x = vertex.x,
      y = vertex.y,
      adj_face = findAdjacentFace(faces, i)
    })
  end
  -- Utils.printTable(input.vertices)

  -- FACES: for each face, find its 3 adjacent faces
  -- an adjacent face is a face that shares two vertices with the current face
  -- for each vertex of a face, we find the opoosite face id, which is
  -- the face that shares the other two vertices with the current face
  for j, face in ipairs(faces) do
    table.insert(mesh.faces, {
      {
        vertex = face[1],
        opp_face = findOppositeFace(faces, j, face[2], face[3]),
      },
      {
        vertex = face[2],
        opp_face = findOppositeFace(faces, j, face[1], face[3]),
      },
      {
        vertex = face[3],
        opp_face = findOppositeFace(faces, j, face[1], face[2]),
      },
    })
  end
  -- Utils.printTable(faces)

  return mesh
end


----------- MAIN -----------

local path_in = "malha.txt"
local path_out = "malha_adj.txt"
local input = parseInput(path_in)
mesh = createDualGraphMesh(input.vertices, input.faces)
writeOutput(path_out, mesh)
print("wrote output to " .. path_out)
