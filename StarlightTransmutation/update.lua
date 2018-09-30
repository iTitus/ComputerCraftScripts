local shell = require("shell")
local PARENT_URL = "https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/StarlightTransmutation/"

function download(name)
  print("Downloading "..name)
  shell.execute("wget -f "..PARENT_URL..name.." "..name)
end

download("bootstrap.lua")
download("update.lua")
download("starlight_transmutation.lua")
