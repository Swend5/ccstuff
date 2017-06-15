-- 6

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

speaker = peripheral.find("speaker")
sensor = peripheral.find("playerSensor")
chest = peripheral.wrap("back")

if not speaker or not sensor or not chest then
  print("Error finding peripherals")
  do return end
end

knownPlayers = {}
itemValueBuy = {}
itemValueSell = {}
itemQty = {}
slotQty = {}
itemSlots = {}
interacting = false
lastName = ""
direction = ""
introduction = [[Hello, I am TradeBot. Welcome to my shop. If you need help, please press the button above me.]]
welcome = [[Welcome back, %d. How may I help you today?]]
goodbye = [[Have a nice day.]]
helpText = [[To the left and right of me are the values of items to buy or sell. To initiate a transaction, press the button left of me. Then place your payment in my inventory, right click me and write the name of the item you want to buy, followed by the amount. Press the button to the right of me for a printout of the current stock.]]




function totalStock(name)
  local total = 0
  for i = 1, chest.getInventorySize() do
    local stack = chest.getStackInSlot(i)
    if stack and stack.name == name then
      total = total + stack.qty
    end
  end
end

-- function takeInventory()
--   for i = 1, chest.getInventorySize() do
--     stack = chest.getStackInSlot(i)
--     if stack then
--       slotQty[i] = stack.qty
--       inventory
--       inventory[stack.name] = stack.qty
--   end
-- end


function greet(name)
  if knownPlayer[name] then
    speaker.speak(string.format(welcome, name), 10)
  else
    speaker.speak(introduction, 10)
  end
  knownPlayer[name] = true
  lastName = name
  interacting = true
end

function sayGoodbye(name)
  speaker.speak(goodbye, 10)
end

function help()
  speaker.speak(helpText, 10)
end

function nearbyPlayer(range)
  players = sensor.getNearbyPlayers()
  for _, p in pairs(players) do
    if p.distance < range then
      return p.name
    end
  end
  return false
end

function transact()
  local query = io.read()
  local line_split = split(query, " ")
  local name = line_split[1]
  local qty = tonumber(line_split[2])

  if not itemValueSell[name] then
    print("Sorry, I do not sell that item.")
    return false
  end
  if qty > totalStock(name) then
    print("Sorry, I do not seem to have enough of that item in stock.")
    return false
  end
  local paymentNeeded = itemValue[name] * qty
  
  print(sf("Do you want to buy %d %s, for a total value of %d? [y/n]", qty, name, paymentNeeded))
  
  local answer = io.read()
  if answer == "y" or answer == "yes" or answer == "Y" then
    -- check total value to make sure the transaction is valid
    local totalValue = 0
    for i = 1, 16 do
      if itemValueBuy[getItemName(slot)] then
        local oneValue = itemValueBuy[getItemName(slot)]
        totalValue = totalValue + getItemCount(slot) * oneValue
      else
        print(sf("You seem to have placed %s in my inventory, but I do not accept that kind of item as payment.", getItemName(slot)))
      end
    end
    if totalValue < paymentNeeded then
      print("Only %d of need %d value provided.")
      return false
    end
    -- take payment
    local payment = 0
    local slot = 1
    while payment < paymentNeeded do
      if itemValueBuy[getItemName(slot)] then
        if slot > 16 then
          print("I am sorry, but I seem to have made a mistake. Please contact my owner and you will be refunded.")
          return false
        end
        local oneValue = itemValueBuy[getItemName(slot)]
        local slotValue = getItemCount(slot) * oneValue
        if slotValue < paymentNeeded - payment then
          -- current stack is not enough to pay the rest, take whole stack
          payment = payment + slotValue
          pullItem(direction, slot, 64)
          slot = slot + 1
        else
          -- current stack is enough to pay, take what is needed
          while payment < paymentNeeded do
            payment = payment + oneValue
            pullItem(direction, slot, 1)
          end
        end
      end
    end
    -- drop requested stuff
    local slot = getEmptySlot()
    if slot == -1 then
      print("My inventory seems to be full. Please remove at least one stack.")
      while slot == -1 do
        sleep(1)
        slot = getEmptySlot()
      end
    end
    turtle.select(slot)
    local numDropped = 0
    for i = 1, chest.getInventorySize() do
      if itemSlots[i] then
        local rest = qty - numDropped
        if slotQty[i] < rest then
          -- enough items in that slot to finish
          slotQty[i] = slotQty[i] - rest
          chest.pushItemIntoSlot(direction, i, slot, rest)
          drop()
          return true
        else
          numDropped = slotQty[i]
          slotQty[i] = 0
          chest.pushItemIntoSlot(direction, i, slot, rest)
          drop()
        end
      end
    end
    print("I am sorry, but I seem to have made a mistake. Please contact my owner and you will be refunded.")
    return false
  end
end

function printStock()
  local stock = {}
  for i = 1, chest.getInventorySize() do
    local stack = c.getStackInSlot(i)
    if stack and itemValueSell[stack.name] then
      if not stock[stack.name] then
        stock[name] = stack.qty
      else
        stock[name] = stock[name] + stack.qty
      end
    end
  end
  for name, qty in pairs(stock) do
    print(name, ":\t", qty)
  end
end

function placeSigns()
  local buyLines = {}
  local sellLines = {}

  for k, v in pairs(itemValueBuy) do
    table.insert(buyLines, k)
    table.insert(buyLines, tostring(v))
  end
  for k, v in pairs(itemValueSell) do
    table.insert(sellLines, k)
    table.insert(sellLines, tostring(v))
  end

  moveForward(2)
  moveRight()
  right()

  local signsNeeded = math.ceil(#buyLines/4)
  moveUp(signsNeeded + 1)
  place("BUY VALUE")
  local curLine = 1
  for i = 1, signsNeeded - 1 do
    moveDown()
    place(buyLines[curLine] .. "\n" .. buyLines[curLine+1] .. "\n" .. buyLines[curLine+2] .. "\n" .. buyLines[curLine+3])
    curLine = curLine + 4
  end
  local lastString = ""
  for i = curLine, #buyLines do
    lastString = lastString .. "\n" .. buyLines[i]
  end
  moveDown()
  place(lastString)

  moveDown()
  moveRight(2)
  left()

  local signsNeeded = math.ceil(#sellLines/4)
  moveUp(signsNeeded + 1)
  place("SELL VALUE")
  local curLine = 1
  for i = 1, signsNeeded - 1 do
    moveDown()
    place(sellLines[curLine] .. "\n" .. sellLines[curLine+1] .. "\n" .. sellLines[curLine+2] .. "\n" .. sellLines[curLine+3])
    curLine = curLine + 4
  end
  local lastString = ""
  for i = curLine, #sellLines do
    lastString = lastString .. "\n" .. sellLines[i]
  end
  moveDown()
  place(lastString)
  moveDown()
  moveLeft()
  moveRight(2)
  turn()
end

function init()
  -- read value file
  for line in io.lines("_values") do
    local line_split = split(line, " ")
    local buysell = line_split[1]
    local name = line_split[2]
    local value = line_split[3]
    if buysell == "buy" then
      itemValueBuy[name] = tonumber(value)
    elseif buysell == "sell" then
      itemValueSell[name] = tonumber(value)
      itemSlots[name] = {}
      itemQty[name] = 0
    end
  end
  -- get turtle direction relative to chest
  if pcall(pullItem, "east", 1, 1) then direction = "east"
  elseif pcall(pullItem, "north", 1, 1) then direction = "north"
  elseif pcall(pullItem, "south", 1, 1) then direction = "south"
  elseif pcall(pullItem, "west", 1, 1) then direction = "west"
  end
  -- check inventory
  for i = 1, chest.getInventorySize() do
    stack = chest.getStackInSlot(i)
    if not stack then
      slotQty[i] = 0
    else
      slotQty[i] = stack.qty
      if itemValueSell[stack.name] then
        itemQty[name] = itemQty[name] + stack.qty
        itemSlots[name][i] = true
      end
    end
  end
  startup = fs.open("startup", "w")
  startup.write([[shell.run("trade")]])
  startup.close()
end


init()
placeSigns()
help()
-- while true do
--   while true do
--     player = nearbyPlayer(4)
--     if player and not interacting then
--       greet(player)
--       break
--     elseif not player and interacting then
--       sayGoodbye(player)
--     end
--     if rs.getInput("top") then
--       help()
--     end
--     if rs.getInput("bottom") then
--       transact()
--     end
--     if rs.getInput("back")
--     os.sleep(1)
--   end
-- end