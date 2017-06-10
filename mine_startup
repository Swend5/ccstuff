if not fs.exists("_mine_info") then
    do return end
end

shell.run("api.lua")

file = fs.open("_mine_info", "r")
params = split(file.readAll(), " ")
file.close()
startY = tonumber(params[1])
y = tonumber(params[2])

moveToY(startY, 1)

shell.run("rm", "_mine_info")
shell.run("rm", "startup")

print("Ready after disrupted mining.")