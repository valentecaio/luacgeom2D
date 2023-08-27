Matrix = require "matrix"

m = Matrix.fromLuaTable{
  {1, 2, 3, 5},
  {3, 2, 1, 5},
  {2, 1, 3, 5},
  {1, 2, 3, 4},
}

print(m:toString())
print('determinant:', m:determinant())
