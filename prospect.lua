-- 1
args = {...}

usageString = "Usage: prospect blockname y step xSize zSize"

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

assert(#args == 5)
blockname = args[1]
y = tonumber(args[2])
step = tonumber(args[3])
xSize = tonumber(args[4])
zSize = tonumber(args[5])

function probe()
  local oldY = y
  while y > 10 do
    if inspectNameDown() == blockname then
      moveToY(oldY, 1)
      selectNonEmptySlot()
      placeDown()
      break
    end
    if detectDown() then
      digDown()
    end
    if down() then
      y = y - 1
    else
      os.sleep(1)
    end
  end
  moveToY(oldY, 1)
end

while true do
  probe()
  while x < xSize - step do
    moveToX(x + step, 1)
    probe()
  end
  if z >= zSize - step then break end
  moveToZ(z + step, 1)
  probe()
  while x >= step do
    moveToX(x + step, 1)
    probe()
  end
  if z >= zSize - step then break end
  moveToZ(z + step, 1)
end

moveToZ(0, 1)
moveToX(0, 1)