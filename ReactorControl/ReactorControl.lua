-- qKKcRJ6p
os.loadAPI("button")

c = peripheral.find("tile_thermalexpansion_cell_resonant_name")
r = peripheral.find("BigReactors-Reactor")
m = peripheral.wrap("right")

local turnOnPercentage = 5
local turnOffPercentage = 95

-- On, Off or Automatic
local mode = "Automatic"
local forceMode = false
local forcedMode = false

local energy = 0
local maxEnergy = 0
local energyPercent = 0

local energyChange = 0
local cColor = colors.white

local rState = false
local rStateText = "OFF"
local rColor = colors.red
local rChange = 0
local rcColor = colors.white

function check()
  energy = c.getEnergyStored()
  maxEnergy = c.getMaxEnergyStored()
  energyPercent = math.floor(((energy/maxEnergy)*100)+0.5)
  
  rState = r.getActive()
  rStateText = "OFF"
  rColor = colors.red
  rChange = r.getEnergyProducedLastTick()
  rcColor = colors.white
  if r.getActive() then
    rStateText = "ON"
    rColor = colors.green
  end
  if rChange > 0 then
    rcColor = colors.green
  end
  if forceMode then
    rStateText = "Force "..rStateText
  end
  
  local oldEnergy = c.getEnergyStored()
  sleep(0.05)
  cColor = colors.white
  energyChange = math.floor((c.getEnergyStored() - oldEnergy)+0.5)
  if energyChange > 0 then
    cColor = colors.green
  elseif energyChange < 0 then
    cColor = colors.red
  end
end

function mainMenu()
  button.clearTable()
  
  -- Mode Switch Buttons
  button.setTable("Automatic", autoMode, "", 3, 13, 3, 3)
  button.setTable("On", doForceMode, true, 15, 25, 3, 3)
  button.setTable("Off", doForceMode, false, 27, 37, 3, 3)
  
  -- button.screen()
  button.toggleButton(mode)
end

function autoMode()
  forceMode = false
  mode = "Automatic"
  writeMode()
end

function doForceMode(newMode)
  forceMode = true
  forcedMode = newMode
  if newMode then
    mode = "On"
  else
    mode = "Off"
  end
  writeMode()
end

function displayData()
  m.clear()
  m.setCursorPos(1,1)
  m.setTextColor(colors.white)
  m.write("Reactor Control v2")
  m.setCursorPos(1,5)
  m.write("Energy: "..comma_value(energy).." RF ("..energyPercent.." %)")
  m.setCursorPos(1,6)
  m.write("Energy Change: ")
  m.setTextColor(cColor)
  m.write(comma_value(energyChange))
  m.setTextColor(colors.white)
  m.write(" RF/t")
  m.setCursorPos(1,7)
  m.setTextColor(colors.white)
  m.write("Reactor: ")
  m.setTextColor(rColor)
  m.write(rStateText)
  m.setTextColor(colors.white)
  m.write(" - ")
  m.setTextColor(rcColor)
  m.write(comma_value(rChange))
  m.setTextColor(colors.white)
  m.write(" RF/t")
end

function reactorLogic()
  if forceMode then
    print("Reactor: "..tostring(rState).." - Forced Mode: "..tostring(forcedMode))
    if rState ~= forcedMode then
	  print("Changing mode to "..tostring(forcedMode))
      r.setActive(forcedMode)
    end
  else
    if energyPercent < turnOnPercentage then
	  if not rState then
        r.setActive(true)
      end
    end
	if energyPercent > turnOffPercentage then
	  if rState then
        r.setActive(false)
	  end
    end
  end
end

function displayScreen()
  check()
  displayData()
  mainMenu()
  reactorLogic()
  
  -- Sleeps 0.5s or until the monitor is touched
  local timerCode = os.startTimer(0.5)
  local event, side, x, y
  repeat
    event, side, x, y = os.pullEvent()
  until event ~= "timer" or timerCode == side
  if event == "monitor_touch" then
    button.checkxy(x,y)
  end
  
  reactorLogic()
end

function comma_value(amount)
  if not amount then
    return "nil"
  end
  if type(amount) ~= "number" then
    return amount
  end
  local formatted = amount
  local swap = false
  if formatted < 0 then 
   formatted = formatted*-1
   swap = true
  end
  while true do
    formatted, k = string.gsub(formatted, "^(%d+)(%d%d%d)", '%1.%2')
    if k == 0 then
      break
    end
  end
  if swap then 
    formatted = "-"..formatted
  end
  return formatted
end

function writeMode()
  file = io.open("mode", "w")
  file:write(textutils.serialize(mode))
  file:close()
end
 
function readMode()
  file = io.open("mode", "r")
  if file then
    mode = textutils.unserialize(file:read("*a"))
    file:close()
  end
  -- Hacky...
  if mode == "Automatic" then
    autoMode()
  elseif mode == "On" then
    doForceMode(true)
  elseif mode == "Off" then
    doForceMode(false)
  end
end

readMode()
while true do
  displayScreen()
end