
-- Usage: queen x z y

args = {...}

shell.run("api")

dp("Queen started...")

-- The queen must be a advanced wireless crafty turtle

-- Start off by setting up a GPS
shell.run("setupgps", "east " .. args[1] .. " " .. args[2] .. " " .. args[3])

-- Make sure the position on track
x, z, y = gps.locate(5)

-- Save position of hive
dp("Saving position of hive:")
io.output("hivepos")
io.write("hiveX = " .. x .. "\n")
io.write("hiveZ = " .. z .. "\n")
io.write("topFloor = " .. y)
io.flush()
shell.run("hivepos")
dp("hiveX: %d\nhiveZ: %d\ntopFloor: %d", hiveX, hiveZ, topFloor)

-- Define rooms
io.output("hiverooms")

 -- TODO

-- Mine out the middle section of the hive
dp("Mining hive midsection")
moveForward(15)
if not selectByName("BlockIronChest") then selectByName("chest") end
place()
turn()
place()
turn()
shell.run("mine", sf("%d %d 2 32", y-1, y-5))