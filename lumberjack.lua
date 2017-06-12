
-- Usage: lumberjack [facing]

DEPRECATED

-- Saplings in slot 1
-- Birch or pine. Pine yields more wood.

args = {...}

shell.run("api", args[1])

startY = y

saplingName = getItemName(1)

while true do

  moveUp(1)
  turtle.select(1)
  for i = 1, 10 do
    moveForward(1)
    place(3) -- 3 for down
  end
  moveRight(1)
  turn()

  -- begin inspecting for trees
  local count = 0
  while count < 8 do
    moveLeft(10)
    right()
    os.sleep(30)
    count = 0
    for i = 1, 10 do
      moveRight(1)
      left()
      if detect() then
        count = count+1
        logName = inspectName()
      end
    end
  end

  -- get 'em
  moveDown(1)
  for i = 1, 10 do
    turtle.select(1); dig()
    while inspectName() == logName do
      dig()
      moveUp(1, 1)
    end
    moveToY(startY)
    moveLeft(1)
    right()
  end

  moveForward(3)
  moveLeft(2)

  -- deposit wood
  for i = 2, 16 do
    turtle.select(i)
    drop()
  end

  turn()

  -- get saplings
  while getItemCount(1) <= 10 do
    _hoover(15)
    moveRight(1)
    right()
    _hoover(15)
    moveLeft(1)
    left()
    _hoover(15)
    moveRight(1)
    right()
    _hoover(15)
    moveLeft(1)
    left()
    moveLeft(4)
    _hoover(15)
    turn()
  end

  moveForward(2)
  moveRight(2)
  left()

end

function _hoover(n)
  for i = 1, n do
    moveForward(1)
    suck()
  end
end