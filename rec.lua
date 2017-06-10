while true do
  event, id, text = os.pullEvent()
  if event == "rednet_message" then
    print(id .. "> " .. text)
  end
end