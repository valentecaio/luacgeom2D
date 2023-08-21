-- Vector class

local Vector = {}
Vector.__index = Vector

function Vector.new(components)
  local self = setmetatable({}, Vector)
  self.components = components
  return self
end

function Vector.scalarProduct(a, b)
  local result = 0
  for i = 1, #a.components do
    result = result + a.components[i] * b.components[i]
  end
  return result
end

function Vector.vectorialProduct(a, b)
  if #a.components ~= 3 or #b.components ~= 3 then
    error("Vectorial product is defined only for 3D vectors.")
  end

  local result = {}
  result[1] = a.components[2] * b.components[3] - a.components[3] * b.components[2]
  result[2] = a.components[3] * b.components[1] - a.components[1] * b.components[3]
  result[3] = a.components[1] * b.components[2] - a.components[2] * b.components[1]
  return Vector.new(result)
end

function Vector:dot(matrix)
  if self.size ~= matrix.rows then
    error("Invalid dimensions for multiplication.")
  end

  local result = Vector.new(matrix.columns)

  for j = 1, matrix.columns do
    local sum = 0
    for i = 1, self.size do
      sum = sum + self.data[i] * matrix:get(i, j)
    end
    result:set(j, sum)
  end

  return result
end

function Vector:toString()
  return "{" .. table.concat(self.components, ", ") .. "}"
end

return Vector
