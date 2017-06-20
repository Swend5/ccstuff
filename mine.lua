-- 3
args = { ... }

usageString = "Usage: mine [current y] [from level] [to level] [size|xsize zsize]"

-- Syntax: mine [current y] [from level] [to level] [size|xsize zsize]
-- Appropriate ender chest in slot 16, if relevant
-- or chest for depositing behind the turtle.
-- Chest with fuel above that.

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

startupString = [[
if not fs.exists("_mine_info") then
  print("Tried to recover, but couldn't access _mine_info.")
  do return end
end

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

file = fs.open("_mine_info", "r")
params = split(file.readAll(), " ")
file.close()
startY = tonumber(params[1])
y = tonumber(params[2])

moveToY(80, 1)
while detectUp() do
  digUp()
  os.sleep(1)
  moveUp()
end

shell.run("rm", "_mine_info")
shell.run("rm", "startup")

print("Ready after disrupted mining.")
]]

discardNames = {
  ["dirt"] = true,
  ["sand"] = true,
  ["cobblestone"] = true,
  ["gravel"] = true,
  ["andesite"] = true,
  ["marble"] = true,
  ["granite"] = true,
}

depositing = false

startY = tonumber(args[1])
y = startY
topLevel = tonumber(args[2])
botLevel = tonumber(args[3])

if #args == 4 then
  xSize = tonumber(args[4])
  zSize = tonumber(args[4])
elseif #args == 5 then
  xSize = tonumber(args[4])
  zSize = tonumber(args[5])
else
  print(usageString)
  do return end
end

print(getItemName == nil)
enderChest = getItemName(16) == "enderChest"
if enderChest then
  dp("Enderchest found")
  max = 15
else
  max = 16
end

-- Print information
print(sf("Mining %d levels from %d to %d in a %dx%d area", topLevel-botLevel+1, topLevel, botLevel, xSize, zSize))

-- Create new startup file
file = fs.open("startup", "w")
file.write(startupString)
file.close()

function updateStartupInfo()
  file = fs.open("_mine_info", "w")
  file.write(startY .. " " .. y)
  file.close()
end

updateStartupInfo()
  

function deposit()
  if enderChest then
    dp("Depositing with enderchest")
    _enderDeposit()
  else
    dp("Depositing without enderchest")
    if getFuelLevel() > 2500 then
      _regularDeposit()
    else
      depositAndRefuel()
    end
  end
end

function _enderDeposit()
  turtle.select(16)
  if not place() then turtle.dig(); place() end
  for i = 1, 15 do
    turtle.select(i)
    drop()
  end
  turtle.select(16)
  dig()
  turtle.select(1)
end

function _regularDeposit()
  depositing = true
  local oldX = x
  local oldZ = z
  local oldY = y

  moveToZ(0, 1)
  moveToX(0, 1)
  moveToY(startY, 1)
  faceXNeg()
  for i = 1, 16 do
    turtle.select(i)
    drop()
  end
  turtle.select(1)
  moveToY(oldY, 1)
  moveToX(oldX, 1)
  moveToZ(oldZ, 1)
  depositing = false
end

function depositAndRefuel()
  depositing = true
  local oldX = x
  local oldZ = z
  local oldY = y

  moveToZ(0, 1)
  moveToX(0, 1)
  moveToY(startY, 1)
  faceXNeg()
  for i = 1, 16 do
    turtle.select(i)
    drop()
  end
  turtle.select(1)

  moveUp()
  while getFuelLevel() < 20000 do
    suck()
    refuel()
    if getItemCount(1) > 0 then
      right()
      drop()
      left()
    end
  end
  moveDown()

  moveToY(oldY, 1)
  moveToX(oldX, 1)
  moveToZ(oldZ, 1)
  depositing = false
end

function refuelWithoutDepositing()
  -- For ender chest turtles
  depositing = true
  local oldX = x
  local oldZ = z
  local oldY = y

  moveToZ(0, 1)
  moveToX(0, 1)
  moveToY(startY + 1, 1)
  faceXNeg()
  if not selectEmptySlot() then
    turn()
    _enderDeposit()
    turn()
    selectEmptySlot()
  end
  while getFuelLevel() < 20000 do
    suck()
    refuel()
    if getItemCount(getSelectedSlot()) > 0 then
      right()
      drop()
      left()
    end
  end
  moveToY(oldY, 1)
  moveToX(oldX, 1)
  moveToZ(oldZ, 1)
  depositing = false
end

function discard()
  compactInventory(1, max)
  for i = 1, max do
    local name = getItemName(i)
    if discardNames[name] then
      turtle.select(i)
      drop()
    end
  end
  turtle.select(1)

  local load = 0
  for i = 1, max do
    if getItemCount(i) > 0 then
      load = load+1
    end
  end
  if load >= max - 2 then
    deposit()
  end
end


-- Override
function dig()
  if turtle.dig() then
    if (not depositing) and isInventoryFull() then discard() end
  end
end

-- Override
function digDown()
  if turtle.digDown() then
    if (not depositing) and isInventoryFull() then discard() end
  end
end

-- Override
function digUp()
  if turtle.digUp() then
    if (not depositing) and isInventoryFull() then discard() end
  end
end

function mine(xSize, zSize, topLevel, botLevel)
  dp("Beginning mine procedure:")
  dp("xSize: %d, zSize %d, top: %d, bot: %d", xSize, zSize, topLevel, botLevel)
  
  moveToY(topLevel+1, 1)
  while y > botLevel do
    _mineLevel(xSize, zSize)
    if getFuelLevel() < xSize * zSize * 1.1 + 100 then
      if not enderchest then
        depositAndRefuel()
      else
        refuelWithoutDepositing()
      end
    end
  end

  if enderChest then _enderDeposit() end

  depositing = true
  moveToZ(0)
  moveToX(0)
  moveToY(startY)
  if not enderChest then
    faceXNeg()
    for i = 1, max do
      turtle.select(i)
      drop()
    end
  end
  faceX()
  depositing = false
end

function _mineLevel(xSize, zSize)
  dp("Mining level...")
  moveToY(y-1, 1)

  updateStartupInfo()

  while z < zSize - 1 do
    moveToX(xSize - 1, 1)
    moveToZ(z + 1, 1)
    moveToX(0, 1)
    moveToZ(z + 1, 1)
  end
  if z == zSize - 1 then
    moveToX(xSize - 1, 1)
  end
  moveToZ(0, 1)
  moveToX(0, 1)
  faceX()
end

--function patch()
--  if  not selectByName("cobblestone")
--  and not selectByName("dirt")
--  and not selectByName("sandstone")
--  then
--    moveToZ(0)
--    moveToX(0)
--    faceX()
--    return false
--  end
--  left()
--  if not detect() then place() end
--  right()
--  if forward() then
--    x = x+dirX
--    z = z+dirZ
--  else
--    os.sleep(1)
--  end
--  return true
--end
--
--function patchLevel()
--  while x < xSize - 1 do
--    faceX()
--    if not patch() then return end
--  end
--  while z < zSize - 1 do
--    faceZ()
--    if not patch() then return end
--  end
--  while x > 0 do
--    faceXNeg()
--    if not patch() then return end
--  end
--  while z > 0 do
--    faceZNeg()
--    if not patch() then return end
--  end
--end

mine(xSize, zSize, topLevel, botLevel)

shell.run("rm", "_mine_info")
shell.run("rm", "startup")
