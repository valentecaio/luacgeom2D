-- Matrix class

local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(rows, columns)
  local self = setmetatable({}, Matrix)
  self.rows = rows
  self.columns = columns
  self.data = {}

  for i = 1, rows do
    self.data[i] = {}
    for j = 1, columns do
      self.data[i][j] = 0
    end
  end

  return self
end

function Matrix.fromLuaTable(luaMatrix)
  local rows = #luaMatrix
  local columns = #luaMatrix[1] -- the number of columns is the length if one row
  local matrix = Matrix.new(rows, columns)
  for i = 1, rows do
    for j = 1, columns do
      matrix:set(i, j, luaMatrix[i][j])
    end
  end
  return matrix
end

function Matrix:set(row, column, value)
  self.data[row][column] = value
end

function Matrix:get(row, column)
  return self.data[row][column]
end

function Matrix:determinant()
  -- Check if matrix is square
  if self.rows ~= self.columns then
    return nil -- Not a square matrix, determinant is not defined
  end
  
  -- Calculate determinant for a 2x2 matrix
  if self.rows == 2 then
    return self.data[1][1] * self.data[2][2] - self.data[1][2] * self.data[2][1]
  end
  
  -- Calculate determinant for a 3x3 matrix
  if self.rows == 3 then
    local a = self.data[1][1]
    local b = self.data[1][2]
    local c = self.data[1][3]
    local d = self.data[2][1]
    local e = self.data[2][2]
    local f = self.data[2][3]
    local g = self.data[3][1]
    local h = self.data[3][2]
    local i = self.data[3][3]
    
    --return a * (e*i - f*h) - b * (d*i - f*g) + c * (d*h - e*g)
    return a*e*i + b*f*g + c*d*h - a*f*h - b*d*i - c*e*g
  end
  
  -- Calculate determinant for a 4x4 matrix
  if self.rows == 4 then
    local a = self.data[1][1]
    local b = self.data[1][2]
    local c = self.data[1][3]
    local d = self.data[1][4]
    local e = self.data[2][1]
    local f = self.data[2][2]
    local g = self.data[2][3]
    local h = self.data[2][4]
    local i = self.data[3][1]
    local j = self.data[3][2]
    local k = self.data[3][3]
    local l = self.data[3][4]
    local m = self.data[4][1]
    local n = self.data[4][2]
    local o = self.data[4][3]
    local p = self.data[4][4]
    
    return a * (f * (k*p - l*o) - g * (j*p - l*n) + h * (j*o - k*n))
         - b * (e * (k*p - l*o) - g * (i*p - l*m) + h * (i*o - k*m))
         + c * (e * (j*p - l*n) - f * (i*p - l*m) + h * (i*n - j*m))
         - d * (e * (j*o - k*n) - f * (i*o - k*m) + g * (i*n - j*m))
  end
  
  return nil
end

function Matrix:mul(other)
  if self.columns ~= other.rows then
    return nil -- Invalid dimensions for multiplication
  end
  
  local result = Matrix.new(self.rows, other.columns)
  
  for i = 1, self.rows do
    for j = 1, other.columns do
      local sum = 0
      for k = 1, self.columns do
        sum = sum + self.data[i][k] * other:get(k, j)
      end
      result:set(i, j, sum)
    end
  end
  
  return result
end

function Matrix:dot(vector)
  if self.columns ~= vector.size then
    return nil -- Invalid dimensions for multiplication
  end
  
  local result = Vector.new(self.rows)
  
  for i = 1, self.rows do
    local sum = 0
    for j = 1, self.columns do
      sum = sum + self.data[i][j] * vector:get(j)
    end
    result:set(i, sum)
  end
  
  return result
end

function Matrix:toString()
  local result = ""
  for i = 1, self.rows do
    result = result .. "{" .. table.concat(self.data[i], ", ") .. "},\n"
  end
  return result
end

return Matrix
