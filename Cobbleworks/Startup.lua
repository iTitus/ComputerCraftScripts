function setState(state)
  file = io.open("state", "w")
  file:write(textutils.serialize(state))
  file:close()
end
 
function getState()
  local state = 0
  file = io.open("state", "r")
  if file then
    state = textutils.unserialize(file:read("*a"))
    file:close()
  end
  return state
end

if getState() == 0 then
  print("Updating files...")
  shell.run("versionChecker")
  setState(1)
  os.reboot()
else
  print("Starting Cobbleworks")
  setState(0)
  shell.run("cobbleworks")
end
