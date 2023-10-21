#!/usr/bin/lua

package.path = package.path .. ";./?/?.lua"
package.path = package.path .. ";../?/?.lua"

local Plot = require("matplotlua")
local Utils = require("utils")


----------- AUXILIARY FUNCTIONS -----------

-- the first line contains the number of vertices (n) and the number of faces (m).
-- the following n lines contain the coordinates of the vertices.
-- the following m lines contain the faces.
-- each face is a list of 3 vertice indices
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
    n = n,
    m = m,
    vertices = vertices,
    faces = faces,
  }
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

-- convert face to string for debugging
function faceToString(face)
  return "Face{" .. face[1] .. ", " .. face[2] .. ", " .. face[3] .. "}"
end

-- generate output in the format:
-- the first line is n and m.
-- the following n lines contain the coordinates of the vertices and the id of an adjacent face.
-- the following m lines contain the faces. 
-- each face is a list of 3 vertice indices followed by a list of 3 adjacent face indices.
function writeOutput(path, mesh)
  local lines = {
    mesh.n .. " " .. mesh.m,
  }
  for _, v in ipairs(mesh.vertices) do
    table.insert(lines, v.x .. " " .. v.y .. " " .. v.adj_face)
  end
  for _,f in ipairs(mesh.faces) do
    -- -1 because lua arrays start at 1
    table.insert(lines, f[1].vertex  -1 .. " " .. f[2].vertex  -1 .. " " .. f[3].vertex  -1
              .. " " .. f[1].opp_face-1 .. " " .. f[2].opp_face-1 .. " " .. f[3].opp_face-1)
  end
  Utils.writeFile(path, lines)
end


function createDualGraphMesh(input)
  -- VERTICES: for each vertex, find ANY adjacent face
  local vertices = {}
  for i, vertex in ipairs(input.vertices) do
    for j, face in ipairs(input.faces) do
      -- print("checking if vertex " .. i .. " appears in face " ..faceToString(face))
      if Utils.listContains(face, i) then
        table.insert(vertices, {
          x = vertex.x,
          y = vertex.y,
          adj_face = j,
        })
        break
      end
    end
  end
  -- Utils.printTable(input.vertices)

  -- FACES: for each face, find its 3 adjacent faces
  -- an adjacent face is a face that shares two vertices with the current face
  -- for each vertex of a face, we find the opoosite face id, which is
  -- the face that shares the other two vertices with the current face
  local faces = {}
  for j, face in ipairs(input.faces) do
    table.insert(faces, {
      {
        vertex = face[1],
        opp_face = findOppositeFace(input.faces, j, face[2], face[3]),
      },
      {
        vertex = face[2],
        opp_face = findOppositeFace(input.faces, j, face[1], face[3]),
      },
      {
        vertex = face[3],
        opp_face = findOppositeFace(input.faces, j, face[1], face[2]),
      },
    })
  end
  -- Utils.printTable(faces)

  -- final adj mesh
  return {
    n = input.n,
    m = input.m,
    vertices = vertices,
    faces = faces,
  }
end


----------- MAIN -----------

local path_in = "malha.txt"
local path_out = "malha_adj.txt"
local input = parseInput(path_in)
mesh = createDualGraphMesh(input)
writeOutput(path_out, mesh)
print("wrote output to " .. path_out)
