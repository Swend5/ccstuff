args = { ... }
ID = tonumber(args[1])
signal = args[2]

rednet.send(ID, signal)
event, id, text = os.pullEvent()
if event == "rednet_message" then
	print(id .. "> " .. text)
end