TURN_ON_PERCENTAGE = 5
TURN_OFF_PERCENTAGE = 95

SLEEP_TIME = 5

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

function getEnergyText()
  return comma_value(getEnergy()) .. " RF"
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
  local w, h = term.getSize()
  
  local eT = getEnergyText()
  local pT = getEnergyPercentageText()
  term.write("Energy: " .. eT .. " (" .. pT .. ")")
  
  local e = getEnergy()
  local c = getCapacity()
  if e > 0 and e < c then -- 0 < e < c
    local p = getEnergy() / getCapacity()
    local dW = floor(((w - 2) * p) + 0.5) + 1
    paintutils.drawFilledBox(2, 2, math.max(1, math.min(width - 2, dW)), 2, colors.green)
  else
    local col
    if e > 0 then -- e = c
      col = colors.green
    else -- e = 0
      col = colors.green
    end
    paintutils.drawFilledBox(2, 2, width - 2, 2, col)
  end
  
  sleep(SLEEP_TIME)
end
