TURN_ON_PERCENTAGE = 5
TURN_OFF_PERCENTAGE = 95

SLEEP_TIME = 5

e = peripheral.wrap("back")

function getEnergy()
  return floor(e.getEnergy() / 8)
end

function getMaxEnergy()
  return floor(e.getMaxEnergy() / 8)
end

function getInput()
  return floor(e.getInput() / 8)
end

function getOutput()
  return floor(e.getOutput() / 8)
end

function getMaxTransfer()
  return floor(e.getTransferCap() / 8)
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

  local w, h = term.getSize()
  local eT = getEnergyText()
  local pT = getEnergyPercentageText()
  
  term.setCursorPos(1, 1)
  term.write("Energy: " .. eT .. " (" .. pT .. ")")
  
  local e = getEnergy()
  local c = getMaxEnergy()
  if e > 0 and e < c then -- 0 < e < c
    local dW = floor(((w - 2) * (e / c)) + 0.5) + 1
    dW = math.max(1, math.min(w - 2, dW))
    paintutils.drawFilledBox(2, 2, dW, 2, colors.green)
    paintutils.drawFilledBox(dW + 1, 2, w - 1, 2, colors.red)
  else
    local col = nil
    if e > 0 then -- e = c
      col = colors.green
    else -- e = 0
      col = colors.green
    end
    paintutils.drawFilledBox(2, 2, w - 2, 2, col)
  end
  
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.setCursorPos(1, 1)
  sleep(SLEEP_TIME)
end
