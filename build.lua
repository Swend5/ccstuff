args = {...}

DEPRECATED

-- Usage
-- build template_file_name

-- Imports

shell.run("rom/apis/io")
shell.run("api")

-- Get material amounts and ids
file = io.open(args[1], "r")
id = {}
amount = {}
slots = {}
currentSlot = 1
while true do

  if currentSlot > 16 then
    print("Not enough room for materials")
    os.exit()
  end

  line = file:read()
  if line == "" then
    break
  end

  splitline = split(line, " ")
  idStr = splitline[1]
  n = tonumber(splitline[2])
  alias = splitline[3]

  id[alias] = idStr
  amount[alias] = n
  slots[alias] = currentSlot
  currentSlot = currentSlot+1
  
  tempn = n
  while tempn > 64 do
    currentSlot = currentSlot+1
    tempn = tempn - 64
  end


    
end

-- Build --
oldX, oldZ, oldY = x, z, y
while true do

  -- read a level of the schematic
  level = {}
  i = 1
  while true do
    line = file:read()
    if line == "" then
      break
    elseif line == nil then
      break
    end
    level[i] = {}
    blocks = split(line, " ")
    j = 0
    for block in blocks do
      j = j+1
      level[i][j] = block
    end
    i = i+1
  end

  -- build the level

  up()
  moveToX(oldX+#level)

  for i = 1, #level do

    if math.fmod(i,2) == 1 then
      faceE()
      -- place first block
      block = level[i][1]
      if not block == "-" then
        select(slots[block])
        place(3) -- 3 for down
      end
      -- place rest
      for j = 2, #level[i] do
        forward()
        block = level[i][j]
        if not block == "-" then
          select(slots[block])
          place(3) -- 3 for down
        end
      end
    else
      faceW()
      -- place first block
      block = level[i][#level[i]]
      if not block == "-" then
        select(slots[block])
        place(3) -- 3 for down
      end
      -- place rest
      for j = #level[i]-1, 1 do
        forward()
        block = level[i][j]
        if not block == "-" then
          select(slots[block])
          place(3) -- 3 for down
        end
      end
    end

    moveToX(x-1)
  end

  moveToZ(oldZ)
  moveToX(oldX)
end

moveToY(oldY)