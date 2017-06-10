lastFuel = -1
print("Current fuel level: " .. turtle.getFuelLevel())
while true do
  for i=1, 16 do
    turtle.select(i)
    turtle.refuel()
  end
  fuel = turtle.getFuelLevel()
  if fuel == lastFuel then
    break
  end
  lastFuel = fuel
  os.sleep(1)
end
print("Refuel complete. Fuel level: " .. turtle.getFuelLevel())