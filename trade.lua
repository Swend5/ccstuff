-- 8

if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

chest = peripheral.wrap("right")
mon = peripheral.find("monitor")

if not mon or not chest then
  print("Error finding peripherals")
  do return end
end

buyValue = {}
sellValue = {}
itemQty = {}
slotQty = {}
itemSlots = {}
direction = ""


function isSold(item)
  if type(item) == "string" then
    return sellValue[item] ~= nil
  elseif type(item) == "number" then
    return sellValue[getItemName(item)] ~= nil
  end
end

function isBought(item)
  if type(item) == "string" then
    return buyValue[item] ~= nil
  elseif type(item) == "number" then
    return buyValue[getItemName(item)] ~= nil
  end
end

function totalStock(name)
  local total = 0
  for i = 1, chest.getInventorySize() do
    local stack = chest.getStackInSlot(i)
    if stack and stack.name == name then
      total = total + stack.qty
    end
  end
end

function transact()
  local query = io.read()
  local line_split = split(query, " ")
  local name = line_split[1]
  local qty = tonumber(line_split[2])

  if not isSold(name) then
    print("Sorry, I do not sell that item.")
    return false
  end

  if qty > totalStock(name) then
    print("Sorry, I do not seem to have enough of that item in stock. Please refer to the table.")
    return false
  end

  local paymentNeeded = itemValue[name] * qty
  
  print(sf("Do you want to buy %d %s, for a total value of %d? [y/n]", qty, name, paymentNeeded))
  
  local answer = io.read()
  if answer == "y" or answer == "yes" or answer == "Y" then
    -- check total value to make sure the transaction is valid
    local totalValue = 0
    for slot = 1, 16 do
      if isBought(slot) then
        local oneValue = buyValue[getItemName(slot)]
        totalValue = totalValue + getItemCount(slot) * oneValue
      else
        print(sf("You seem to have placed %s in my inventory, but I do not accept that kind of item as payment. Please refer to the table.", getItemName(slot)))
      end
    end
    if totalValue < paymentNeeded then
      print(sf("Only %d of needed %d value provided.", totalValue, paymentNeeded))
      return false
    end
    -- take payment
    local payment = 0
    local slot = 1
    while payment < paymentNeeded do
      if slot > 16 then
        print("I am sorry, but I seem to have made a mistake. Please contact my owner and you will be refunded.")
        return false
      end
      if isBought(slot) then
        local singleValue = buyValue[getItemName(slot)]
        local slotValue = getItemCount(slot) * singleValue
        if slotValue < paymentNeeded - payment then
          -- current stack is not enough to pay the rest, take whole stack
          payment = payment + slotValue
          pullItem(direction, slot, 64)
          slot = slot + 1
        else
          -- current stack is enough to pay, take what is needed
          while payment < paymentNeeded do
            payment = payment + singleValue
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
          itemSlots[name][i] = false
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
    if stack and isSold(stack.name) then
      local name = stack.name
      local qty = stack.qty
      if not stock[name] then
        stock[name] = qty
      else
        stock[name] = stock[name] + qty
      end
    end
  end
  for name, qty in pairs(stock) do
    print(name, ":\t", qty)
  end
end

  -- local buyLines = {}
  -- local sellLines = {}

  -- for k, v in pairs(buyValue) do
  --   table.insert(buyLines, k)
  --   table.insert(buyLines, tostring(v))
  -- end
  -- for k, v in pairs(sellValue) do
  --   table.insert(sellLines, k)
  --   table.insert(sellLines, tostring(v))
  -- end

function init()
  -- read value file
  for line in io.lines("_values") do
    local line_split = split(line, " ")
    local buysell = line_split[1]
    local name = line_split[2]
    local value = line_split[3]
    if buysell == "buy" then
      buyValue[name] = tonumber(value)
    elseif buysell == "sell" then
      sellValue[name] = tonumber(value)
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
      if isSold(stack.name) then
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