args = { ... }

-- Syntax: mine [from level] [to level] [size|xsize zsize]
-- Must have appropriate ender chest in slot 16

if not api then shell.run("api") end

lx = 0
lz = 0
ldirX = 1
ldirZ = 0

if y == 0 then
  write("GPS not available. Please enter current y: ")
  y = tonumber(io.read())
end
startY = y

topLevel = tonumber(args[1])
botLevel = tonumber(args[2])

if #args == 3 then
  xSize = tonumber(args[3])
  zSize = tonumber(args[3])
elseif #args == 4 then
  xSize = tonumber(args[3])
  zSize = tonumber(args[4])
end

enderChest = getItemName(16) == "enderChest"
if enderChest then
  max = 15
else
  max = 16
end

-- Print information
dp("Mining %d levels from %d to %d in a %dx%d area", topLevel-botLevel+1, topLevel, botLevel, xSize, zSize)

-- Calculate fuel approximate fuel needed, ask for a refuel if fuel is too low
fuelNeeded = (topLevel - botLevel + 1) * xSize * zSize * 1.1
dp("Fuel level: %d of %d", getFuelLevel(), fuelNeeded)
while getFuelLevel() < fuelNeeded do
  print("Not enough fuel. Please put fuel in the first slot and press any key.")
  io.read()
  if not refuel() then exit() end
  dp("Fuel level: %d of %d", getFuelLevel(), fuelNeeded)
end

-- Create new startup
shell.run("copy", "mine_startup startup")
file = fs.open("_mine_info", "w")
file.write(startY .. " " .. y)
file.close()

function deposit()
  if enderChest then
    dp("Depositing with enderchest")
    _enderDeposit()
  else
    dp("Depositing without enderchest")
    _regularDeposit()
  end
end

function _enderDeposit()
  select(16)
  if not place() then turtle.dig(); place() end
  for i = 1, 15 do
    select(i)
    drop()
  end
  select(16)
  dig()
  select(1)
end

function _regularDeposit()
  oldX = lx
  oldZ = lz
  oldY = y
  offset = 0

  if ldirX == -1 or ldirZ == -1 and not lz == 1 then
    lmoveToX(lx+1, 1)
    offset = 1
  end

  lmoveToZ(0, 1)
  lmoveToX(0, 1)
  moveToY(startY, 1)
  lfaceW()
  for i = 1, 16 do
    select(i)
    drop()
  end
  alreadyDiscarded = false
  moveToY(oldY, 1)
  lmoveToX(oldX+offset, 1)
  lmoveToZ(oldZ, 1)
  lmoveToX(lx-offset, 1)
end


alreadyDiscarded = false
function discard()
  if alreadyDiscarded then
    deposit()
  end

  sortInv(1, max)
  for i = 1, max do
    name = getItemName(i)
    if name == "dirt"
    or name == "cobblestone"
    or name == "gravel"
    then
      select(i)
      drop()
    end
  end
  select(1)

  local load = 0
  for i = 1, max do
    if getItemCount(i) > 0 then
      load = load+1
    end
  end
  if load >= 12 then alreadyDiscarded = true end
end


-- Override
function dig()
  if turtle.dig() then
    if isInventoryFull(1, max) then discard() end
  end
end

-- Override
function digDown()
  if turtle.digDown() then
    if isInventoryFull(1, max) then discard() end
  end
end

-- Override
function digUp()
  if turtle.digUp() then
    if isInventoryFull(1, max) then discard() end
  end
end

function mine(xSize, zSize, topLevel, botLevel)
  dp("Beginning mine procedure:")
  dp("xSize: %d, zSize %d, top: %d, bot: %d", xSize, zSize, topLevel, botLevel)
  moveToY(topLevel+1, 1)
  while y > botLevel do
    _mineLevel(xSize, zSize)
  end

  if enderChest then _enderDeposit() end

  lmoveToZ(0, 1)
  lmoveToX(0, 1)
  moveToY(startY, 1)
  if not enderChest then
    lfaceW()
    for i = 1, max do
      select(i)
      drop()
    end
  end
  lfaceE()
end

function _mineLevel(xSize, zSize)
  dp("Mining level...")
  moveDown(1, 1)

  -- Update startup stuff
  file = fs.open("_mine_info", "w")
  file.write(startY .. " " .. y)
  file.close()

  lmoveToX(xSize-1, 1)
  while lx > 1 do
    lmoveToZ(zSize-1, 1)
    lmoveToX(lx-1, 1)
    lmoveToZ(1, 1)
    lmoveToX(lx-1, 1)
  end
  lmoveToZ(zSize-1, 1)
  if lx == 1 then
    lmoveToX(lx-1, 1)
  end
  lmoveToZ(0, 1)
  faceE()
end

mine(xSize, zSize, topLevel, botLevel)

shell.run("rm", "_mine_info")
shell.run("rm", "startup")

function dig() turtle.dig() end
function digDown() turtle.digDown() end
function digUp() turtle.digUp() end
