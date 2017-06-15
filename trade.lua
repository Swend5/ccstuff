speaker = peripheral.wrap("left")
sensor = peripheral.wrap("right")

function doSpeak()
  speaker.speak("Welcome")
end

function playerNearby(range)
  players = sensor.getNearbyPlayers()
  for _, p in pairs(players) do
    if p.distance < range then
      return true
    end
  end
  return false
end

while true do
  while true do
    if playerNearby() then
      doSpeak()
      break
    end
    os.sleep(1)
  end
  os.sleep(60)
end