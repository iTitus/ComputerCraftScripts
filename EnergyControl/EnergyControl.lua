TURN_ON_P = 50 / 100
TURN_OFF_P = 95 / 100

RS_SIDE = "back"

SLEEP_TIME = 1
AVERAGE_SAMPLES = 30

m = peripheral.find("monitor")
m.setTextScale(2)
term.redirect(m)

e = peripheral.find("draconic_rf_storage")

rs_state = true
io_list = {current=0}
io_avg = 0

function getEnergy()
  return e.getEnergyStored()
end

function getMaxEnergy()
  return e.getMaxEnergyStored()
end

function getTransfer()
  return e.getTransferPerTick() 
end

function getPercentage()
  return 100 * (getEnergy() / getMaxEnergy())
end

function getEnergyText()
  return comma_value(getEnergy()) .. " RF"
end

function getMaxEnergyText()
  return comma_value(getMaxEnergy()) .. " RF"
end

function getPercentageText()
  return floor(getPercentage(), 0.01) .. " %"
end

function getIOText()
  return comma_value(round(io_avg, 0.01)) .. " RF/t"
end

function updateIO()
  local io_current = getTransfer()
  io_list.current = (io_list.current + 1) % AVERAGE_SAMPLES
  io_list[io_list.current] = io_current
  
  io_avg = 0
  local io_size = #io_list
  for _, v in ipairs(io_list) do
    io_avg = io_avg + (v / io_size)
  end
end

function updateRS()
  local p = getEnergy() / getMaxEnergy()
  if p >= TURN_OFF_P then
    rs_state = false
  end
  if p <= TURN_ON_P then
    rs_state = true
  end
  redstone.setOutput(RS_SIDE, rs_state)
end

function comma_value(n)
  local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
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
  m.clear()

  updateIO()
  updateRS()
  
  local w, h = m.getSize()
  local eT = getEnergyText()
  local cT = getMaxEnergyText()
  local pT = getPercentageText()
  local ioT = getIOText()
  
  m.setCursorPos(1, 1)
  m.write("Cur: " .. eT)
  m.setCursorPos(1, 2)
  m.write("Max: " .. cT)
  m.setCursorPos(1, 3)
  m.write("Percent: " .. pT)
  m.setCursorPos(1, 4)
  m.write("IO: " .. ioT)
  
  m.setCursorPos(1, 5)
  local s = "State: Generators "
  if rs_state then
    s = s .. "ON"
  else
    s = s .. "OFF"
  end
  m.write(s)
  
  local line = 7
  
  local e = getEnergy()
  local c = getMaxEnergy()
  local p = e / c
  if e > 0 and e < c then -- 0 < e < c
    local dW = floor(((w - 2) * p) + 0.5) + 1
    dW = math.max(1, math.min(w - 2, dW))
    paintutils.drawFilledBox(2, line, dW, line + 1, colors.green)
    paintutils.drawFilledBox(dW + 1, line, w - 1, line + 1, colors.red)
  else
    local col = nil
    if e > 0 then -- e = c
      col = colors.green
    else -- e = 0
      col = colors.green
    end
    paintutils.drawFilledBox(2, line, w - 2, line, col)
  end
  paintutils.drawPixel(math.max(1, math.min(w - 1, floor((w - 1) * TURN_ON_P) + 1)), line + 2, colors.yellow)
  paintutils.drawPixel(math.max(1, math.min(w - 1, floor((w - 1) * TURN_OFF_P) + 1)), line + 2, colors.yellow)
  
  m.setBackgroundColor(colors.black)
  sleep(SLEEP_TIME)
end
