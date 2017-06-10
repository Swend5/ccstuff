lastFuel = -1
while true do
  for i=1, 16 do
    turtle.select(i)
    turtle.refuel()
  end
  fuel = turtle.getFuelLevel()
  print(turtle.getFuelLevel())
  if fuel == lastFuel then
    break
  end
  lastFuel = fuel
  os.sleep(1)
end