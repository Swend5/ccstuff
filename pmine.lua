args = { ... }

-- Syntax: pmine [present height] [from level] [to level] [size|size size]
-- Must have appropriate ender chest in slot 16
-- Must have chunk loader in slot 15



    args = { ... }

    -- Syntax: mine [present height] [from level] [to level]
    -- Must have appropriate ender chest in slot 16

    shell.run("api", "0 0 " .. args[1])

    startHeight = tonumber(args[1])
    topLevel = tonumber(args[2])
    bottomLevel = tonumber(args[3])

    xSize = 16
    ySize = 16

    -- Print information
    print("Mining " .. topLevel - bottomLevel + 1 .. " levels from " .. topLevel .. " to " .. bottomLevel .. " in a ".. xSize .. "x" .. ySize .. " area")

    -- Calculate fuel approximate fuel needed, ask for a refuel if fuel is too low
    fuelNeeded = (topLevel - bottomLevel + 1) * xSize * ySize * 1.1
    print("Fuel level: " .. getFuelLevel() .. " of " .. fuelNeeded)
    while getFuelLevel() < fuelNeeded do
        print("Not enough fuel. Please put fuel in the first slot and press any key.")
        io.read()
        if not refuel() then exit() end
        print("Fuel level: " .. getFuelLevel() .. " of " .. fuelNeeded)
    end

    function deposit()
        shell.run("refuel")
        select(16)
        if not turtle.place() then turtle.dig(); turtle.place() end
        for i=1, 14 do
                select(i)
                drop()
        end
        select(16)
        dig()
        select(1)
    end

    -- Override
    function dig()
        if turtle.dig() then
            if isInventoryFull(1, 15) then deposit() end
        end
    end

    -- Override
    function digDown()
        if turtle.digDown() then
            if isInventoryFull(1, 15) then deposit() end
        end
    end

    -- Override
    function digUp()
        if turtle.digUp() then
            if isInventoryFull(1, 15) then deposit() end
        end
    end

while true do

    -- Move down to the top level

    moveToH(topLevel+1, 1)

    -- Then begin mining each level

    while h > bottomLevel do
        moveToH(h-1, 1)
        local levelsMined = topLevel - h + 1
        print("Mining level " .. levelsMined .. " of " .. topLevel - bottomLevel + 1)
        moveToX(xSize-1, 1)
        while x > 0 do
            moveToY(ySize-1, 1)
            moveToX(x-1, 1)
            moveToY(1, 1)
            if x > 0 then moveToX(x-1, 1) end
        end
        moveToY(0, 1)
    end

    -- Reset in next chunk

    if (dirX == -1 and y < 1)
    or dirY == -1
    then moveToX(x+1, 1) end
    moveToY(0, 1)
    moveToX(0, 1)
    moveToH(startHeight, 1)
    turn()
    moveToX(xSize-2,1)
    select(15)
    turtle.place()
    moveToX(0,1)
    turtle.dig()
    moveToX(xSize-2,1)
    moveToY(y+1,1)
    moveToX(xSize,1)
    moveToY(y-1,1)
    x,y=0,0
    select(1)
end