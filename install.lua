waaaat
ghstr = "https://raw.githubusercontent.com/Swend5/ccstuff/master/%s.lua %s"
programs = {
    "mine",
    "api",
    "refuel",
    "pmine",
    "vgps",
    "build",
    "setupgps",
    "lumberjack",
    "queen",
}

for _, program in ipairs(programs) do
    shell.run("delete", program)
    shell.run("wget", string.format(ghstr, program, program))
end
