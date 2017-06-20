args = {...}

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

assert(#args == 3)
blockname = args[1]
step = tonumber(args[2])
xSize = tonumber(args[3])
zSize = tonumber(args[4])

function probe()
  local oldY = y
  while y > ty do
    if inspectNameDown() == blockname then
      moveToY(oldY, 1)
      selectNonEmptySlot()
      placeDown()
      break
    if detectDown() then
      digDown()
    end
    if down() then
      y = y - 1
    else
      os.sleep(1)
    end
  end
end

while z < zSize - step do
  probe()
  while x < xSize - step do
    moveToX(x + step, 1)
    probe()
  end
  moveToZ(z + step, 1)
end