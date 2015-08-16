-- qKKcRJ6p
os.loadAPI("button")
os.loadAPI("paint")

c = peripheral.find("tile_thermalexpansion_cell_resonant_name")
r = peripheral.find("BigReactors-Reactor")
m = peripheral.find("monitor")

local turnOnPercentage = 5
local turnOffPercentage = 95

local width = 0
local height = 0

-- main or edit
local menuType = "main"

-- On, Off or Automatic
local mode = "Automatic"
local forceMode = false
local forcedMode = false

local energy = 0
local maxEnergy = 0
local energyPercent = 0

local rState = false
local rStateText = "OFF"
local rColor = colors.red
local rChange = 0
local rcColor = colors.white

function check()

  width, height = m.getSize()

  energy = c.getEnergyStored()
  maxEnergy = c.getMaxEnergyStored()
  energyPercent = math.floor(((energy/maxEnergy)*100)+0.5)
  
  rState = r.getActive()
  rStateText = "OFF"
  rColor = colors.red
  rChange = math.floor(r.getEnergyProducedLastTick()+0.5)
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
end

function mainMenu()
  button.clearTable()
  
  button.setTable("Edit Values", switchMenu, "edit", 27, 37, 1, 1)
  -- Mode Switch Buttons
  button.setTable("Automatic", autoMode, "", 3, 13, 3, 3)
  button.setTable("On", doForceMode, true, 15, 25, 3, 3)
  button.setTable("Off", doForceMode, false, 27, 37, 3, 3)
  
  -- button.screen()
  button.toggleButton(mode)
end

function editMenu()
  button.clearTable()
  
  button.setTable("Cancel", switchMenu, "main", 8, 18, 10, 10)
  button.setTable("OK", savePercent, "", 22, 32, 10, 10)
  
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

function switchMenu(newMenu)
  menuType = newMenu
end

function savePercent()
  writePercent()
  switchMenu("main")
end

function displayMainData()
  m.clear()
  m.setCursorPos(1,1)
  m.setTextColor(colors.white)
  m.write("Reactor Control v2")
  m.setCursorPos(1,5)
  m.write("Energy: "..comma_value(energy).." RF ("..energyPercent.." %)")
  m.setCursorPos(1,11)
  m.write("Reactor: ")
  m.setTextColor(rColor)
  m.write(rStateText)
  m.setTextColor(colors.white)
  m.setCursorPos(1,12)
  m.write("Reactor Production: ")
  m.setTextColor(rcColor)
  m.write(comma_value(rChange))
  m.setTextColor(colors.white)
  m.write(" RF/t")
  
  local dW = math.floor(((width-2) * (energy/maxEnergy))+0.5)+1
  if energy > 0 then
    paint.drawFilledBox(2, 7, dW, 9, colors.green)
  end
  if energy < maxEnergy then
    paint.drawFilledBox(dW, 7, width-1, 9, colors.red)
  end
  
end

function displayEditData()
  m.clear()
  m.setCursorPos(1,1)
  m.write("On: "..turnOnPercentage)
  m.setCursorPos(1,2)
  m.write("Off: "..turnOffPercentage)
end

function reactorLogic()
  if forceMode then
    if rState ~= forcedMode then
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
  if menuType == "main" then
    displayMainData()
    mainMenu()
  elseif menuType == "edit" then
    displayEditData()
	editMenu()
  end
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
  local negative = false
  if formatted < 0 then 
   formatted = formatted*-1
   negative = true
  end
  while true do
    formatted, k = string.gsub(formatted, "^(%d+)(%d%d%d)", '%1.%2')
    if k == 0 then
      break
    end
  end
  if negative then 
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

function writePercent()
  file = io.open("percentOn", "w")
  file:write(textutils.serialize(turnOnPercentage))
  file:close()
  file = io.open("percentOff", "w")
  file:write(textutils.serialize(turnOffPercentage))
  file:close()
end
 
function readPercent()
  file = io.open("percentOn", "r")
  if file then
    turnOnPercentage = textutils.unserialize(file:read("*a"))
    file:close()
  end
  file = io.open("percentOff", "r")
  if file then
    turnOffPercentage = textutils.unserialize(file:read("*a"))
    file:close()
  end
end

readMode()
readPercent()
while true do
  displayScreen()
end
