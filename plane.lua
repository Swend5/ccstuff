args = {...}

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

assert(#args == 2)
xSize = tonumber(args[1])
zSize = tonumber(args[2])


function placeToX(tx)
  while x < tx do
    faceX()
    selectNonEmptySlot()
    placeDown()
    if forward() then
      x = x + dirX
      z = z + dirZ
    else
      os.sleep(1)
    end
  end
  while x > tx do
    faceXNeg()
    selectNonEmptySlot()
    placeDown()
    if forward() then
      x = x + dirX
      z = z + dirZ
    else
      os.sleep(1)
    end
  end
end
 
function placeToZ(tz)
  while z < tz do
    faceZ()
    selectNonEmptySlot()
    placeDown()
    if forward() then
      x = x + dirX
      z = z + dirZ
    else
      os.sleep(1)
    end
  end
  while z > tz do
    faceZNeg()
    selectNonEmptySlot()
    placeDown()
    if forward() then
      x = x + dirX
      z = z + dirZ
    else
      os.sleep(1)
    end
  end
end


while z < zSize - 1 do
  placeToX(xSize - 1)
  placeToZ(z + 1)
  placeToX(0)
  placeToZ(z + 1)
end
if z == zSize - 1 then
  placeToX(xSize - 1)
end
moveToZ(0)
moveToX(0)
faceX()