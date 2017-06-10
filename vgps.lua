-- Usage
-- vgps x z y target-y

args = {...}

x =  tonumber(args[1])
z =  tonumber(args[2])
y =  tonumber(args[3])
ty = tonumber(args[4])

-- file = open("startup")
-- io.write("shell.run(\"gps\", \"host " ..)

while y < ty do
  if turtle.up() then y = y+1 else os.sleep(1) end
end
pos = x .. " " .. z .. " " .. y
io.output("startup")
io.write("shell.run(\"gps\", \"host " .. pos .. "\")")
shell.run("gps", "host " .. pos)