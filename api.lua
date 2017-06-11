-- API of doom
 
-- Usage:
-- Preface script with 'if not api then shell.run("api", [facing]) end'
-- Facing is
-- "east"  or 0 (DEFAULT)
-- "south" or 1
-- "west"  or 2
-- "north" or 3

if api == true then
  do return end
else
  api = true
end

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
 
apiargs = {...}
if #apiargs > 0 then
  dp("API: called with arg: %s", apiargs[1])
end

x, z, y = gps.locate(5)
dp("API: gps located %d %d %d", x, z, y)
if not x then x, z, y = 0, 0, 0 end
dirX, dirZ = 1, 0
 
if     apiargs[1] == "south" or apiargs[1] == 1 then
  dirX, dirZ = 0, 1
elseif apiargs[1] == "west"  or apiargs[1] == 2 then
  dirX, dirZ = -1, 0
elseif apiargs[1] == "north" or apiargs[1] == 3 then
  dirX, dirZ = 0, -1
end
 
-------------------------------------------------------------------------------
-- MOVEMENT
-------------------------------------------------------------------------------

-- d == 1 for digging, d != 1 for not

-- Relative movement

function moveForward(n, d)
  d = d or 0
  moves = 0
  dp("Moving forward %d time(s)", n)
  while moves < n do
    if d == 1 and detect() then
      dig()
    end
    if forward() then
      x = x+dirX
      z = z+dirZ
      lx = lx+ldirX
      lz = lz+ldirZ
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
  d = d or 0
  moves = 0
  dp("Moving up %d time(s)")
  while moves < n do
    if d == 1 and detectUp() then
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
  d = d or 0
  moves = 0
  dp("Moving down %d time(s)", d)
  while moves < n do
    if d == 1 and detectDown() then
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
  d = d or 0
  dp("Moving from x=%d to x=%d", x, tx)
  if x < tx then
    faceE()
    moveForward(tx-x, d)
  elseif x > tx then
    faceW()
    moveForward(x-tx, d)
  end
end
 
function moveToZ(tz, d)
  d = d or 0
  dp("Moving from z=%d to z=%d", z, tz)
  if z < tz then
    faceS()
    moveForward(tz-z, d)
  elseif z > tz then
    faceN()
    moveForward(z-tz, d)
  end
end
 
function moveToY(ty, d)
  d = d or 0
  dp("Moving from y=%d to y=%d", y, ty)
  if y < ty then
    moveUp(ty-y, d)
  elseif y > ty then
    moveDown(y-ty, d)
  end
end

-- Local absolute movement

lx = 0
lz = 0
ly = 0
ldirX = 1
ldirZ = 0 

function lmoveToX(tx, d)
  d = d or 0
  dp("Local moving from lx=%d to lx=%d", lx, tx)
  if lx < tx then
    lfaceE()
    moveForward(tx-lx, d)
  elseif lx > tx then
    lfaceW()
    moveForward(lx-tx, d)
  end
end
 
function lmoveToZ(tz, d)
  d = d or 0
  dp("Local moving from lz=%d to lz=%d", lz, tz)
  if lz < tz then
    lfaceS()
    moveForward(tz-lz, d)
  elseif lz > tz then
    lfaceN()
    moveForward(lz-tz, d)
  end
end


-- Turn functions, with implemented direction
 
function right()
  if turnRight() then
    dirX, dirZ = -dirZ, dirX
    ldirX, ldirZ = -ldirZ, ldirX
  end
end
 
function left()
  if turnLeft() then
    dirX, dirZ = dirZ, -dirX
    ldirX, ldirZ = ldirZ, -ldirX
  end
end
 
function turn()
  right()
  right()
end
 
-- Turn towards a specific direction
-- n = negative
 
function faceE()
  if dirX == 0 then
    if dirZ == 1 then left() else right() end
  elseif dirX == -1 then
    turn()
  end
end
 
function faceW()
  if dirX == 0 then
    if dirZ == 1 then right() else left() end
  elseif dirX == 1 then
    turn()
  end
end
 
function faceS()
  if dirZ == 0 then
    if dirX == 1 then right() else left() end
  elseif dirZ == -1 then
    turn()
  end
end
 
function faceN()
  if ldirZ == 0 then
    if ldirX == 1 then left() else right() end
  elseif ldirZ == 1 then
    turn()
  end
end

function lfaceE()
  if ldirX == 0 then
    if ldirZ == 1 then left() else right() end
  elseif ldirX == -1 then
    turn()
  end
end
 
function lfaceW()
  if ldirX == 0 then
    if ldirZ == 1 then right() else left() end
  elseif ldirX == 1 then
    turn()
  end
end
 
function lfaceS()
  if ldirZ == 0 then
    if ldirX == 1 then right() else left() end
  elseif ldirZ == -1 then
    turn()
  end
end
 
function lfaceN()
  if ldirZ == 0 then
    if ldirX == 1 then left() else right() end
  elseif ldirZ == 1 then
    turn()
  end
end

function getFacing()
  if     dirX ==  1 then return "east"
  elseif dirZ ==  1 then return "south"
  elseif dirX == -1 then return "west"
  else                   return "north"
  end
end
 
-------------------------------------------------------------------------------
-- BUILDING
-------------------------------------------------------------------------------
 
-- 'placeTo' functions
-- Kinda like moveTo, except placing a block for each step
-- d = direction. 1 for up, 2 for right, 3 for down, 4 for left
 
function placeToX(tx, d)
  while x < tx do
    faceN()
    place(d)
    if forward() then x = x+1 else os.sleep(1) end
  end
  while x > tx do
    faceS()
    place(d)
    if forward() then x = x-1 else os.sleep(1) end
  end
  place(d)
end
 
function placeToZ(tz, d)
-- Move to target z 'tz'.
  while z < tz do
    faceE()
    place(d)
    if forward() then z = z+1 else os.sleep(1) end
  end
  while z > tz do
    faceW()
    place(d)
    if forward() then z = z-1 else os.sleep(1) end
  end
  place(d)
end
 
function placeToY(ty, d)
-- Move to target height 'th'.
  while y > ty do
    place(d)
    if down() then y = y-1 else os.sleep(1) end
  end
  while y < ty do
    place(d)
    if up() then y = y+1 else os.sleep(1) end
  end
end

function moveToPos(tx, tz, ty, d)
  moveToX(tx, d)
  moveToZ(tz, d)
  moveToY(ty, d)
end
 
function place(d)
  if not d then turtle.place() end
  if d == 1 then placeUp()
  elseif d == 2 then right(); place(); left()
  elseif d == 3 then placeDown()
  elseif d == 4 then left(); place(); right() end
end
 
-------------------------------------------------------------------------------
-- INVENTORY
-------------------------------------------------------------------------------
 
function sortInv(first, last)
  dp("Sorting inventory...")
  for i=first+1, last do
    turtle.select(i)
    for j=first, i-1 do
      if turtle.compareTo(j) then
        turtle.transferTo(j)
      end
    end
  end
end
 
function isInventoryFull(first, last)
  dp("Checking for full inventory")
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
      select(i)
      return true
    end
  end
  return false
end


-------------------------------------------------------------------------------
-- MISC
-------------------------------------------------------------------------------

-- Split a string into a list at chosen separator
function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
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

-------------------------------------------------------------------------------
-- ITEM NAME LISTS
-------------------------------------------------------------------------------
--[[
chestNames = {["chest"] = true, ["BlockIronChest"] = true}
function isChest(name)
  if chestNames[name] then
    return true
  else
    return false
  end
end
--]]
