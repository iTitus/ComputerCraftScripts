TURN_ON_P = 5 / 100
TURN_OFF_P = 95 / 100

ENERGY_SIDE = "back"
RS_SIDE = "right"

SLEEP_TIME = 1
AVERAGE_SAMPLES = 30

e = peripheral.wrap(ENERGY_SIDE)
rs_state = true
i_list, o_list, io_list = {first=0}, {first=0}, {first=0}
i_avg, o_avg, io_avg = 0, 0, 0

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

function getPercentageText()
  return floor(getPercentage(), 0.01) .. " %"
end

function getInputText()
  return comma_value(round(i_avg, 0.01)) .. " RF/t"
end

function getOutputText()
  return comma_value(round(o_avg, 0.01)) .. " RF/t"
end

function getIOText()
  return comma_value(round(io_avg, 0.01)) .. " RF/t"
end

function getMaxTransferText()
  return comma_value(getMaxTransfer()) .. " RF/t"
end

function updateIO()
  local i, o = getInput(), getOutput()
  i_list.first, o_list.first, io_list.first  = (i_list.first + 1) % AVERAGE_SAMPLES, (o_list.first + 1) % AVERAGE_SAMPLES, (io_list.first + 1) % AVERAGE_SAMPLES
  i_list[i_list.first] = i
  o_list[o_list.first] = o
  io_list[io_list.first] = i - o
  
  i_avg, o_avg, io_avg = 0, 0, 0
  local i_size, o_size, io_size = #i_list, #o_list, #io_list
  for _, v in ipairs(i_list) do
    i_avg = i_avg + (v / i_size)
  end
  for _, v in ipairs(o_list) do
    o_avg = o_avg + (v / o_size)
  end
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
  term.clear()

  updateIO()
  updateRS()
  
  local w, h = term.getSize()
  local eT = getEnergyText()
  local pT = getPercentageText()
  local iT = getInputText()
  local oT = getOutputText()
  local ioT = getIOText()
  local tT = getMaxTransferText()
  
  term.setCursorPos(1, 1)
  term.write("Energy: " .. eT .. " (" .. pT .. ")")
  term.setCursorPos(1, 2)
  term.write("In: " .. iT)
  term.setCursorPos(1, 3)
  term.write("Out: " .. oT)
  term.setCursorPos(1, 4)
  term.write("IO: " .. ioT)
  term.setCursorPos(1, 5)
  local s = "State: Generators "
  if rs_state then
    s = s .. "ON"
  else
    s = s .. "OFF"
  end
  term.write(s)
  
  local e = getEnergy()
  local c = getMaxEnergy()
  local p = e / c
  if e > 0 and e < c then -- 0 < e < c
    local dW = floor(((w - 2) * p) + 0.5) + 1
    dW = math.max(1, math.min(w - 2, dW))
    paintutils.drawFilledBox(2, 7, dW, 7, colors.green)
    paintutils.drawFilledBox(dW + 1, 7, w - 1, 7, colors.red)
  else
    local col = nil
    if e > 0 then -- e = c
      col = colors.green
    else -- e = 0
      col = colors.green
    end
    paintutils.drawFilledBox(2, 7, w - 2, 7, col)
  end
  paintutils.drawPixel(math.max(1, math.min(w - 1, floor((w - 1) * TURN_ON_P) + 1)), 8, colors.yellow)
  paintutils.drawPixel(math.max(1, math.min(w - 1, floor((w - 1) * TURN_OFF_P) + 1)), 8, colors.yellow)
  
  term.setBackgroundColor(colors.black)
  sleep(SLEEP_TIME)
end
