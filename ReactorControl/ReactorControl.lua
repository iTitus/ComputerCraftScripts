os.loadAPI("button")
os.loadAPI("paint")

c = peripheral.find("tile_thermalexpansion_cell_resonant_name")
reactors = {}
m = peripheral.find("monitor")

local turnOnPercentage = 5
local turnOffPercentage = 95

local tempTurnOnPercent = -1
local tempTurnOffPercent = -1

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

function findReactors()
  local pType = "BigReactors-Reactor"
  local pNum = 1
  for n, p in pairs(peripheral.getNames()) do
    if peripheral.getType(p) == pType then
      reactors[pNum] = {}
      reactors[pNum]["reactor"] = peripheral.wrap(p)
      pNum = pNum + 1
    end 
  end
end

function check()

  width, height = m.getSize()

  energy = c.getEnergyStored()
  maxEnergy = c.getMaxEnergyStored()
  energyPercent = math.floor(((energy/maxEnergy)*100)+0.5)
  
  for i, t in ipairs(reactors) do
    local r = t["reactor"]
    t["rState"] = r.getActive()
    t["rStateText"] = "OFF"
    t["rColor"] = colors.red
    local rChange = math.floor(r.getEnergyProducedLastTick() + 0.5)
    t["rChange"] = rChange
    t["rcColor"] = colors.white
    
    if r.getActive() then
      t["rStateText"] = "ON"
      t["rColor"] = colors.green
    end
    if rChange > 0 then
      t["rcColor"] = colors.green
    end
    if forceMode then
      t["rStateText"] = "Force "..t["rStateText"]
    end
    
  end
  
end

function mainMenu()
  button.clearTable()
  
  button.setTable("Edit", gotoEdit, "", 27, 37, 1, 1)
  -- Mode Switch Buttons
  button.setTable("Automatic", autoMode, "", 3, 13, 3, 3)
  button.setTable("On", doForceMode, true, 15, 25, 3, 3)
  button.setTable("Off", doForceMode, false, 27, 37, 3, 3)
  
  -- button.screen()
  button.toggleButton(mode)
end

function editMenu()
  button.clearTable()
  
  -- Changing buttons for On-percent
  button.setTable("On - 1", changeOnPercent, -1, 3, 13, 3, 3)
  button.setTable("On - 5", changeOnPercent, -5, 15, 25, 3, 3)
  button.setTable("On - 10", changeOnPercent, -10, 27, 37, 3, 3)
  button.setTable("On + 1", changeOnPercent, 1, 3, 13, 5, 5)
  button.setTable("On + 5", changeOnPercent, 5, 15, 25, 5, 5)
  button.setTable("On + 10", changeOnPercent, 10, 27, 37, 5, 5)
  
  button.setTable("On Default", changeToDefault, true, 27, 37, 1, 1)
  
  -- Changing buttons for Off-percent
  button.setTable("Off - 1", changeOffPercent, -1, 3, 13, 10, 10)
  button.setTable("Off - 5", changeOffPercent, -5, 15, 25, 10, 10)
  button.setTable("Off - 10", changeOffPercent, -10, 27, 37, 10, 10)
  button.setTable("Off + 1", changeOffPercent, 1, 3, 13, 12, 12)
  button.setTable("Off + 5", changeOffPercent, 5, 15, 25, 12, 12)
  button.setTable("Off + 10", changeOffPercent, 10, 27, 37, 12, 12)
  
  button.setTable("Off Default", changeToDefault, false, 27, 37, 8, 8)
  
  -- Exit buttons
  button.setTable("Apply", apply, "", 8, 18, 15, 15)
  button.setTable("Cancel", cancel, "", 22, 32, 15, 15)
  
  button.screen()
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

function apply()
  button.flash("Apply")
  turnOnPercentage = tempTurnOnPercent
  turnOffPercentage = tempTurnOffPercent
  writePercent()
  switchMenu("main")
end

function cancel()
  button.flash("Cancel")
  tempTurnOnPercent = -1
  tempTurnOffPercent = -1
  switchMenu("main")
end

function gotoEdit()
  button.flash("Edit")
  tempTurnOnPercent = turnOnPercentage
  tempTurnOffPercent = turnOffPercentage
  switchMenu("edit")
end
  
function changeOnPercent(by)
  local buttonName = "On "
  if by > 0 then
    buttonName = buttonName.."+ "
  elseif by < 0 then
    buttonName = buttonName.."- "
  end
  buttonName = buttonName..math.abs(by)
  button.flash(buttonName)
  tempTurnOnPercent = math.max(math.min(tempTurnOnPercent + by, tempTurnOffPercent - 1), 0)
end

function changeOffPercent(by)
  local buttonName = "Off "
  if by > 0 then
    buttonName = buttonName.."+ "
  elseif by < 0 then
    buttonName = buttonName.."- "
  end
  buttonName = buttonName..math.abs(by)
  button.flash(buttonName)
  tempTurnOffPercent = math.min(math.max(tempTurnOffPercent + by, tempTurnOnPercent + 1), 100)
end

function changeToDefault(percentType)
  local buttonName = " Default"
  if percentType then
    buttonName = "On"..buttonName
  else
    buttonName = "Off"..buttonName
  end
  button.flash(buttonName)
  if percentType then
    tempTurnOnPercent = 5
  else
    tempTurnOffPercent = 95
  end
end

function displayMainData()
  m.clear()
  m.setCursorPos(1, 1)
  m.setTextColor(colors.white)
  m.write("Reactor Control v2")
  m.setCursorPos(1, 5)
  m.write("Energy: "..comma_value(energy).." RF ("..energyPercent.." %)")
  m.setCursorPos(1, 11)
  m.write("Reactor  |    State    |  Production")
  
  for i, t in ipairs(reactors) do
    m.setCursorPos(1, 11 + i)
    m.setTextColor(colors.white)
    m.write(tostring(i))
    m.setCursorPos(10, 11 + i)
    m.write("|  ")
    m.setTextColor(t["rColor"])
    m.write(t["rStateText"])
    m.setCursorPos(24, 11 + i)
    m.setTextColor(colors.white)
    m.write("|  ")
    m.setTextColor(t["rcColor"])
    m.write(comma_value(t["rChange"]))
    m.setTextColor(colors.white)
    m.write(" RF/t")
  end
  
  m.setCursorPos(1, 16)
  local rChangeSum = 0
  local rcColorSum = colors.white
  for i, t in ipairs(reactors) do
    rChangeSum = rChangeSum + t["rChange"]
  end
  if rChangeSum > 0 then
    rcColorSum = colors.green
  end
  m.write("Total Production: ")
  m.setTextColor(rcColorSum)
  m.write(comma_value(rChangeSum))
  m.setTextColor(colors.white)
  m.write(" RF/t")

  m.setCursorPos(1, 18)
  m.write("Turning reactor on at "..turnOnPercentage.." %")
  m.setCursorPos(1, 19)
  m.write("Turning reactor off at "..turnOffPercentage.." %")
  
  local dW = math.floor(((width - 2) * (energy / maxEnergy)) + 0.5) + 1
  if energy > 0 then
    paint.drawFilledBox(2, 7, dW, 9, colors.green)
  end
  if energy < maxEnergy then
    paint.drawFilledBox(dW, 7, width-1, 9, colors.red)
  end
  
end

function displayEditData()
  m.clear()
  m.setCursorPos(1, 1)
  m.write("Turning on at "..tempTurnOnPercent.." %")
  m.setCursorPos(1, 8)
  m.write("Turning off at "..tempTurnOffPercent.." %")
end

function reactorLogic()
  for i, t in ipairs(reactors) do
    local r = t["reactor"]
    if forceMode then
      if t["rState"] ~= forcedMode then
        r.setActive(forcedMode)
      end
    else
      if energyPercent <= turnOnPercentage then
        if not t["rState"] then
          r.setActive(true)
        end
      end
      if energyPercent >= turnOffPercentage then
        if t["rState"] then
          r.setActive(false)
        end
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
  -- Reset to default
  if turnOnPercentage < 0 or turnOnPercentage > 100 or turnOffPercentage < 0 or turnOffPercentage > 100 or turnOnPercentage >= turnOffPercentage or turnOffPercentage <= turnOnPercentage then
    print("Error while reading percent values: Out of bounds. Resetting...")
    turnOnPercentage = 5
    turnOffPercentage = 95
  end
end

findReactors()
readMode()
readPercent()
while true do
  displayScreen()
end
