TURN_ON_PERCENTAGE = 5
TURN_OFF_PERCENTAGE = 95

SLEEP_TIME = 5
F_T = "100 %"

e = peripheral.wrap("back")

function getEnergy()
  return floor(e.getEnergy() / 8)
end

function getCapacity()
  return floor(e.getMaxEnergy() / 8)
end

function getPercentage()
  return 100 * e.getEnergy() / e.getMaxEnergy()
end

function getEnergyText(amount)
  return comma_value(amount) .. " RF"
end

function getEnergyPercentageText()
  return floor(getPercentage(), 0.01) .. " %"
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

function sgn(v)
  return (v >= 0 and 1) or -1
end

function round(v, bracket)
  bracket = bracket or 1
  return math.floor((v / bracket) + sgn(v) * 0.5) * bracket
end

function floor(v, bracket)
  bracket = bracket or 1
  return math.floor(v / bracket) * bracket
end

while true do
  term.clear()
  term.setCursorPos(1, 1)
  
  local eT = getEnergyText(getEnergy())
  local cT = getEnergyText(getCapacity())
  local pT = getEnergyPercentageText()
  
  term.write("Energy:")
  
  local x, y = term.getCursorPos()
  term.setCursorPos(x + (cT:len() - eT:len()), y)
  term.write(eT .. " / " .. cT .. " (")
  
  x, y = term.getCursorPos()
  term.setCursorPos(x + (F_T:len() - pT:len()), y)
  term.write(pT .. ")")
  
  sleep(SLEEP_TIME)
end
