local shell = require("shell")
local os = require("os")

function setState(state)
  file = io.open("state", "w")
  file:write(state)
  file:close()
end
 
function getState()
  local state = "0"
  file = io.open("state", "r")
  if file then
    state = file:read("*a")
    file:close()
  end
  return state
end

if getState() == "0" then
  print("Updating files...")
  shell.execute("update")
  setState("1")
  os.shutdown(true)
else
  print("Starting Starlight Transmutation")
  setState("0")
  shell.execute("starlight_transmutation")
end
