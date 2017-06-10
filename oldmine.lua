args = { ... }

-- Syntax: mine [present height] [from level] [to level] [size|size size] [rednet ID]

x, y = 0, 0
dirX, dirY = 1, 0
alreadyDiscarded = false
done = false

h = tonumber(args[1]); sh = tonumber(args[1])
topLevel = tonumber(args[2])
bottomLevel = tonumber(args[3])

if #args == 5 then
	xSize = tonumber(args[4])
	ySize = tonumber(args[4])
	ID = tonumber(args[5])
elseif #args == 6 then
	xSize = tonumber(args[4])
	ySize = tonumber(args[5])
	ID = tonumber(args[6])
end

print("Initializing..\n")
print("Mining " .. topLevel - bottomLevel + 1 .. " levels from " .. topLevel .. " to " .. bottomLevel .. " in a ".. xSize .. "x" .. ySize .. " area")

fuelNeeded = (topLevel - bottomLevel + 1) * xSize * ySize * 1.1
print("Fuel level: " .. turtle.getFuelLevel() .. " of " .. fuelNeeded)

while turtle.getFuelLevel() < fuelNeeded do
	print("Not enough fuel. Please put fuel in the first slot.")
	io.read()
	if not turtle.refuel() then exit() end
	print("Fuel level: " .. turtle.getFuelLevel() .. " of " .. fuelNeeded)
end

function moveToX(tx)
-- Move to target x 'tx'.
	if x < tx then
		while x < tx do
			if dirX == 0 then
				if dirY == 1 then left() else right() end
			elseif dirX == -1 then
				right(); right()
			end
			if turtle.detect() then
				dig()
			else
				if turtle.forward() then x = x+1 end
			end
		end
	elseif x > tx then
		while x > tx do
			if dirX == 0 then
				if dirY == 1 then right() else left() end
			elseif dirX == 1 then
				right(); right()
			end
			if turtle.detect() then
				dig()
			else
				if turtle.forward() then x = x-1 end
			end
		end
	end
end

function moveToY(ty)
-- Move to target y 'ty'.
	if y < ty then
		while y < ty do
			if dirY == 0 then
				if dirX == 1 then right() else left() end
			elseif dirY == -1 then
				right(); right()
			end
			if turtle.detect() then
				dig()
			else
				if turtle.forward() then y = y+1 end
			end
		end
	elseif y > ty then
		while y > ty do
			if dirY == 0 then
				if dirX == 1 then left() else right() end
			elseif dirY == 1 then
				right(); right()
			end
			if turtle.detect() then
				dig()
			else
				if turtle.forward() then y = y-1 end
			end
		end
	end
end

function moveToH(th)
-- Move to target height 'th'.
	if h > th then
		while h > th do
			if turtle.detectDown() then
				digDown()
			else
				if turtle.down() then h = h-1 end
			end
		end
	elseif h < th then
		while h < th do
			if turtle.detectUp() then
				digUp()
			else
				if turtle.up() then h = h+1 end
			end
		end
	end
end

function right()
	if turtle.turnRight() then dirX, dirY = -dirY, dirX end
end
 
function left()
	if turtle.turnLeft() then dirX, dirY = dirY, -dirX end
end

function sortInv()
	for i=2, 13 do
		turtle.select(i)
		for j=1, i do
			if turtle.compareTo(j) then
				turtle.transferTo(j)
			end
		end
	end
end

function discard()
	if not alreadyDiscarded then
		sortInv()
		print("Inventory full. Discarding..")
		for i=1, 13 do
			turtle.select(i)
			if turtle.compareTo(14)
			or turtle.compareTo(15)
			or turtle.compareTo(16)
			then
				turtle.drop()
			end
			turtle.select(1)
		end
		local load = 0
		for i=1, 13 do
			if turtle.getItemCount(i) > 0 then
				load = load + 1
			end
		end
		if load >= 10 then alreadyDiscarded = true end
	end
	if isInventoryFull() then
		print("Inventory still full. Depositing..")
		deposit()
	end
end

function isInventoryFull()
	local load = 0
	for i=1, 13 do
		if turtle.getItemCount(i) > 0 then
			load = load + 1
		end
	end
	return load >= 13
end

function dig()
	if turtle.dig() then
		if isInventoryFull() then discard() end
	end
end

function digDown()
	if turtle.digDown() then
		if isInventoryFull() then discard() end
	end
end

function digUp()
	if turtle.digUp() then
		if isInventoryFull() then discard() end
	end
end

function deposit()
	local pX, pY, pH = x, y, h
	local offset = 0
	if dirX == -1 and y < 1 then moveToX(x+1); offset = 1
	elseif dirY == -1 then moveToX(x+1); offset = 1 end
	moveToY(0)
	moveToX(0)
	moveToH(sh)
	for i=1, 13 do
		turtle.select(i)
		turtle.drop()
	end
	turtle.select(1)
	alreadyDiscarded = false
	if done then return end
	print("Done depositing. Returning...")
	moveToH(pH)
	moveToX(pX+offset)
	moveToY(pY)
	if offset == 1 then moveToX(pX) end
end

-- Move down to the top level

moveToH(topLevel+1)

-- Then begin mining each level

while h > bottomLevel do
	moveToH(h-1)
	local levelsMined = topLevel - h + 1
	print("Mining level " .. levelsMined .. " of " .. topLevel - bottomLevel + 1)
	moveToX(xSize-1)
	while x > 0 do
		moveToY(ySize-1)
		moveToX(x-1)
		moveToY(1)
		if x > 0 then moveToX(x-1) end
	end
	moveToY(0)
end

done = true
deposit()
right(); right()