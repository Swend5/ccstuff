args = {...}

-- Must be run first time:
-- - with XX wireless turtles in slot 1
-- - with a disk drive in slot 2
-- - with a floppy disk in slot 3

dp("Setting up GPS...")

if not api then shell.run("api", args[1]) end

x = tonumber(args[2])
z = tonumber(args[3])
y = tonumber(args[4])

dp("setupgps: x=%d z=%d y=%d", x, z, y)

function setupGPS()
  -- >=4 wireless turtles in slot 1
  -- disk drive in slot 2
  -- floppy in slot 3
  oldY = y
  moveToY(205)

  _setup1GPS()

  moveToY(200)
  moveRight(5)
  left()

  _setup1GPS()

  moveLeft(10)
  right()

  _setup1GPS()

  moveRight(5)
  moveLeft(5)

  _setup1GPS()

  moveBack(5)
  turn()
  moveToY(oldY)
end

function _setup1GPS()
  select(1); turtle.place() -- place turtle
  moveBack(1)
  turn()
  select(2); turtle.place() -- place drive in front of turtle
  select(3); drop() -- insert disk
  io.output("disk/startup")
  vgpsArgs = x+2*dirX .. " " .. z+2*dirZ .. " " .. y .. " " .. y
  s = [[shell.run("pastebin", "get RhbgvdjL update")
shell.run("update")
shell.run("vgps", "]] .. vgpsArgs .. "\")"
  io.write(s) -- write startup script for turtle
  io.flush()
  moveLeft(1)
  moveRight(2)
  c = peripheral.wrap("right")
  c.turnOn()
  moveBack(1)
  left()
  select(3); suck()
  select(2); dig()
  moveForward(1)
  left()
end

setupGPS()