rednet.open("right")
rednet.open("left")

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  t={}
  i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

while true do
  event, ID, text = os.pullEvent()
  if event == "rednet_message" then
    print(text)
    split(text, ".")
    outID = text[1]
    outMsg = text[2]
    rednet.send(tonumber(outID), outMsg)
  end
end