print("Current fuel level: " .. turtle.getFuelLevel())
for i=1, 16 do
  turtle.select(i)
  turtle.refuel()
end
turtle.select(1)
print("Refuel complete. Fuel level: " .. turtle.getFuelLevel())