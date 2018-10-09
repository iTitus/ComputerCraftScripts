local shell = require("shell")
local PARENT_URL = "https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/AEControl/"

function download(name)
  print("Downloading "..name)
  shell.execute("wget -f "..PARENT_URL..name.." "..name)
end

download(".shrc")
download("bootstrap.lua")
download("update.lua")
download("ae_control.lua")
