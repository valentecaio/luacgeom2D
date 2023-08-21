-- -- main.lua (Love2D script)

-- function love.load()
--   points = {
--       {100, 100},
--       {200, 200},
--       {300, 150},
--       {400, 250}
--   }
-- end

-- function love.draw()
--   love.graphics.setColor(255, 255, 255) -- Set color to white

--   -- Draw lines between consecutive points
--   for i = 1, #points - 1 do
--       local x1, y1 = points[i][1], points[i][2]
--       local x2, y2 = points[i + 1][1], points[i + 1][2]
--       love.graphics.line(x1, y1, x2, y2)
--   end
-- end


Matrix = require "matrix"

m = Matrix.fromLuaTable{
  {1, 2, 3, 5},
  {3, 2, 1, 5},
  {2, 1, 3, 5},
  {1, 2, 3, 4},
}

print(m:toString())
print('determinant:', m:determinant())
