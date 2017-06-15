if fs.exists("api") then
  shell.run("api")
elseif fs.exists("api.lua") then
  shell.run("api.lua")
else
  print("Error: couldn't find api.")
  do return end
end

speaker = peripheral.find("speaker")
sensor = peripheral.wrap("playerSensor")
chest = peripheral.wrap("chest")

if not speaker or not sensor or not chest then
  print("Error finding peripherals")
  do return end
end

knownPlayers = {}
itemValue = {}
itemQty = {}
slotQty = {}
itemSlots = {}
interacting = false
lastName = ""
introduction = [[Hello, I am TradeBot. Welcome to my shop. If you need help, please press the button above me.]]
welcome = [[Welcome back, %d. How may I help you today?]]
goodbye = [[Have a nice day.]]
helpString = [[To the left and right of me are the values of items to buy or sell. To carry out a transaction, right click me, place your payment in my inventory, and write the name of the item you want to buy, followed by the amount. Write "stock" to get the current items in the shop.]]




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
    speaker.speak(string.format(welcome, name), 5)
  else
    speaker.speak(introduction, 5)
  end
  knownPlayer[name] = true
  lastName = name
  interacting = true
end

function sayGoodbye(name)
  speaker.speak(goodbye)
end

function help()


function nearbyPlayer(range)
  players = sensor.getNearbyPlayers()
  for _, p in pairs(players) do
    if p.distance < range then
      return p.name
    end
  end
  return false
end

function init()
  local vFile = fs.open("_values", "r")
  if not vFile then
    print("Error, could not find value file")
  end
  for line in f:lines() do
    local line_split = split(line, " ")
    local item = line_split[1]
    local value = line_split[2]
    itemValue[name] = tonumber(value)
    itemQty[name] = 0
    itemSlots[name] = {}
  end
  for i = 1, chest.getInventorySize() do
    stack = chest.getStackInSlot(i)
    if not stack then
      slotQty[i] = 0
    else
      itemQty[name] = itemQty[name] + stack.qty
      slotQty[i] = stack.qty
      table.insert(itemSlots[name], i)
    end
  end
  startup = fs.open("startup", "w")
  startup.write([[shell.run("trade")]])
  startup.close()
end

init()
while true do
  while true do
    player = nearbyPlayer(4)
    if player and not interacting then
      greet(player)
      break
    elseif not player and interacting then
      sayGoodbye(player)
    end
    if rs.getInput("top") then
      help()
    end
    os.sleep(1)
  end
end