local shell = require("shell")
local comp = require("computer")

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
  comp.shutdown(true)
else
  print("Starting AE Control")
  setState("0")
  shell.execute("ae_control")
end
