c = peripheral.find("tile_thermalexpansion_cell_resonant_name")
r = peripheral.find("BigReactors-Reactor")
m = peripheral.find("monitor")

local turnOnPercentage = 5
local turnOffPercentage = 95
local forceOff = false

local oldEnergy = -1

while true do
  local energy = c.getEnergyStored()
  local max = c.getMaxEnergyStored()
  local percentage = (energy*100)/max
  local pString = math.floor(percentage+0.5).." %"
  
  local rState = "OFF"
  local rColor = colors.red
  if forceOff then
    rState = "Force OFF"
  elseif r.getActive() then
    rState = "ON"
    rColor = colors.green
  end
  
  local change = "Calculating"
  local cColor = colors.white
  if oldEnergy > 0 then
    change = math.floor(((energy - oldEnergy)/20)+0.5)
    if change > 0 then
      cColor = colors.green
    elseif change < 0 then
      cColor = colors.red
    end
   end
  oldEnergy = energy

  local energyText = "Energy: "..energy.." RF ("..pString..")"
  local changeText = "Energy Change: "..change.." RF/t"
  local reactorText = "Reactor: "..rState
  
  m.clear()
  m.setCursorPos(1,1)
  m.setTextScale(1.5)
  m.setTextColor(colors.white)
  m.write(energyText)
  m.setCursorPos(1,2)
  m.write("Energy Change: ")
  m.setTextColor(cColor)
  m.write(change.." RF/t")
  m.setCursorPos(1,3)
  m.setTextColor(colors.white)
  m.write("Reactor: ")
  m.setTextColor(rColor)
  m.write(rState)
  
  print(energyText.." - "..reactorText)

  if not forceOff and percentage < turnOnPercentage then
    r.setActive(true)
  end
  if forceOff or percentage > turnOffPercentage then
    r.setActive(false)
  end

  sleep(1)
end