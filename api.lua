-- API
 
-- Usage:
-- shell.run("api")

-- "Include guard"
if api then
  do return end
end

debug = false

-- DEBUG PRINT
function dp(...)
  if debug then
    print(sf(...))
  end
end

function sf(...)
  return string.format(...)
end

-------------------------------------------------------------------------------
-- IMPORTS
-------------------------------------------------------------------------------
 
shell.run("rom/apis/turtle/turtle")
shell.run("rom/apis/rednet")
 
-------------------------------------------------------------------------------
-- VARIABLES
-------------------------------------------------------------------------------
 
--apiargs = {...}

x, z, y = 0, 0, 0
dirX, dirZ = 1, 0
 
-------------------------------------------------------------------------------
-- MOVEMENT
-------------------------------------------------------------------------------

-- d == 1 for digging, d != 1 for not

-- Relative movement

function moveForward(n, d)
  local n = n or 1
  local d = d or false
  local moves = 0
  dp("Moving forward %d time(s)", n)
  while moves < n do
    if d and detect() then
      dig()
    end
    if forward() then
      x = x+dirX
      z = z+dirZ
      moves = moves+1
    else
      os.sleep(1)
    end
  end
end

function moveBack(n, d)
  turn()
  moveForward(n, d)
end

function moveRight(n, d)
  right()
  moveForward(n, d)
end

function moveLeft(n, d)
  left()
  moveForward(n, d)
end

function moveUp(n, d)
  local n = n or 1
  local d = d or false
  local moves = 0
  dp("Moving up %d time(s)", n)
  while moves < n do
    if d and detectUp() then
      digUp()
    end
    if up() then
      y = y+1
      moves = moves+1
    else
      os.sleep(1)
    end
  end
end

function moveDown(n, d)
  local n = n or 1
  local d = d or false
  local moves = 0
  dp("Moving down %d time(s)", n)
  while moves < n do
    if d and detectDown() then
      digDown()
    end
    if down() then
      y = y-1
      moves = moves+1
    else
      os.sleep(1)
    end
  end
end

-- Absolute movement
 
function moveToX(tx, d)
  local d = d or false
  dp("Moving from x=%d to x=%d", x, tx)
  while x < tx do
    faceX()
    if d and detect() then
      dig()
    end
    faceX()
    if forward() then
      x = x+dirX
      z = z+dirZ
    else
      os.sleep(1)
    end
  end
  while x > tx do
    faceXNeg()
    if d and detect() then
      dig()
    end
    faceXNeg()
    if forward() then
      x = x+dirX
      z = z+dirZ
    else
      os.sleep(1)
    end
  end
end
 
function moveToZ(tz, d)
  local d = d or false
  dp("Moving from z=%d to z=%d", z, tz)
  while z < tz do
    faceZ()
    if d and detect() then
      dig()
    end
    faceZ()
    if forward() then
      x = x+dirX
      z = z+dirZ
    else
      os.sleep(1)
    end
  end
  while z > tz do
    faceZNeg()
    if d and detect() then
      dig()
    end
    faceZNeg()
    if forward() then
      x = x+dirX
      z = z+dirZ
    else
      os.sleep(1)
    end
  end
end
 
function moveToY(ty, d)
  local d = d or false
  dp("Moving from y=%d to y=%d", y, ty)
  while y < ty do
    if d and detectUp() then
      digUp()
    end
    if up() then
      y = y+1
    else
      os.sleep(1)
    end
  end
  while y > ty do
    if d and detectDown() then
      digDown()
    end
    if down() then
      y = y-1
    else
      os.sleep(1)
    end
  end
end

-- Turn functions, with implemented direction

function right()
  if turnRight() then
    dirX, dirZ = -dirZ, dirX
  end
end
 
function left()
  if turnLeft() then
    dirX, dirZ = dirZ, -dirX
  end
end
 
function turn()
  right()
  right()
end
 
-- Turn towards a specific direction
-- Neg = opposite direction
 
function faceX()
  if dirX == 0 then
    if dirZ == 1 then left() else right() end
  elseif dirX == -1 then
    turn()
  end
end
 
function faceXNeg()
  if dirX == 0 then
    if dirZ == 1 then right() else left() end
  elseif dirX == 1 then
    turn()
  end
end
 
function faceZ()
  if dirZ == 0 then
    if dirX == 1 then right() else left() end
  elseif dirZ == -1 then
    turn()
  end
end
 
function faceZNeg()
  if dirZ == 0 then
    if dirX == 1 then left() else right() end
  elseif dirZ == 1 then
    turn()
  end
end

-------------------------------------------------------------------------------
-- INVENTORY
-------------------------------------------------------------------------------
 
function compactInventory(first, last)
  -- Runs through each pair of items and tries to add one to the
  -- other if they are the same
  dp("Sorting inventory...")
  local first = first or 1
  local last = last or 16
  for i=first+1, last do
    --turtle.select(i)
    local name1 = getItemName(i)
    for j=first, i-1 do
      local name2 = getItemName(i)
      if name1 == name2 then
        turtle.select(i)
        turtle.transferTo(j)
      end
    end
  end
end

function isInventoryFull(first, last)
  dp("Checking for full inventory")
  local first = first or 1
  local last = last or 16
  local load = 0
  for i=first, last do
    if getItemCount(i) > 0 then
      load = load + 1
    end
  end
  return load >= last-first+1
end

function selectByName(name)
  dp("Select by name on %q", name)
  for i = 1, 16 do
    if getItemName(i) == name then
      turtle.select(i)
      return true
    end
  end
  return false
end

function getEmptySlot()
  for i = 1, 16 do
    if getItemCount(i) == 0 then
      return i
    end
  end
  return -1
end

function selectEmptySlot()
  local i = getEmptySlot()
  if i == -1 then
    return false
  else
    turtle.select(i)
    return true
  end
end

function moveToEmptySlot(slot)
  local emptySlot = getEmptySlot()
  if emptySlot == -1 then return false end
  transferTo(emptySlot)
  return true
end


-------------------------------------------------------------------------------
-- MISC
-------------------------------------------------------------------------------

-- Split a string into a list at chosen separator
function split(inputstr, sep)
  if sep == nil then
    local sep = "%s"
  end
  local t={}
  local i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function run(programName, ...)
  if fs.exists(programName) then
    shell.run(programName, ...)
  elseif fs.exists(programName .. ".lua") then
    shell.run(programName .. ".lua", ...)
  else
    print("Could not run \'" .. programName .. "\'.")
  end
end

-------------------------------------------------------------------------------
-- IDENTIFICATION
-------------------------------------------------------------------------------

function getItemName(slot)
  if getItemCount(slot) == 0 then
    return nil
  end
  local name = getItemDetail(slot).name
  local splitname = split(name, ":")
  return splitname[2]
end

function getItemMod(slot)
  if getItemCount(slot) == 0 then
    return nil
  end
  local name = getItemDetail(slot).name
  local splitname = split(name, ":")
  return splitname[1]
end

function inspectName()
  local success, details = inspect()
  if not success then return nil end
  local splitname = split(details.name, ":")
  return splitname[2]
end

function inspectMod()
  local success, details = inspect()
  if not success then return nil end
  local splitname = split(details.name, ":")
  return splitname[1]
end


print("API loaded succesfully")
api = true
