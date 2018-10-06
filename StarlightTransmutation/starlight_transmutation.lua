local comp = require("computer")
local com  = require("component")
local t    = require("term")
local os   = require("os")
local r    = require("robot")
local s    = require("sides")
local n    = com.navigation

local HOME            = { facing=s.west, x=-15.5, y=130.5, z=52.5 }
local INPUT           = s.south
local OUTPUT          = s.east
local ENERGY_TRESHOLD = 0.99
local WORK            = {}

------------------------------

function fill_work()
  -- assuming HOME is in the south-east corner and
     -- one block below the 3x3 work area
  local y = HOME.y + 1
  local size = 3
  for z = 0, 1 - size, -1 do
    local odd   = i % 2 == 1
    local start = if odd then  0        else 1 - size
    local end_  = if odd then  1 - size else 0
    local step  = if odd then -1        else 1
    for x = start, end_, step do
	  table.insert(WORK, { x=x, y=y, z=z })
	end
  end
end

t.clear()
t.setCursor(1, 1)
fill_work()
print("Starlight Transmutation!")

function rotate_to(side)
  local facing = n.getFacing()
  while facing ~= side do
    r.turnRight()
	facing = n.getFacing()
  end
end

function move_forward(n)
  for i = 1, 10, 1 do
    while not r.forward() do
	  os.sleep(0.1)
	end
  end
end

function go_to(x, y, z)
  local d_x, d_y, d_z = HOME.X - x, HOME.y - y, HOME.z - z
  if d_x ~= 0 then
    local facing_name = if d_x < 0 then "pos" else "neg" end .. "x"
	rotate_to(s[facing_name])
	move_forward(abs(d_x))
  end
  if d_y ~= 0 then
    local facing_name = if d_y < 0 then "pos" else "neg" end .. "y"
	rotate_to(s[facing_name])
	move_forward(abs(d_y))
  end
  if d_z ~= 0 then
    local facing_name = if d_z < 0 then "pos" else "neg" end .. "z"
	rotate_to(s[facing_name])
	move_forward(abs(d_z))
  end
end

function go_home()
  local x, y, z = n.getPosition()
  go_to(x, y, z)
end

function prep_inv()
  rotate_to(OUTPUT)
  for i = 2, 15, 1 do
    r.select(i)
    r.drop()
  end
  r.select(16)
  local count = r.count()
  if count > 1
    r.drop(count - 1)
  end
  rotate_to(INPUT)
  r.select(1)
  r.suck()
end

function not_ready()
  if comp.energy() < ENERGY_TRESHOLD * comp.maxEnergy() then
    return true
  end
  if r.count(1) < 9 do
    return true
  end
  for i = 2, 15, 1 do
    if r.count(i) > 0 do
	  return true
	end
  end
  if r.count(16) ~= 1 do
    return true
  end
  return false
end

function wait_until_ready()
  while not_ready() do
    os.sleep(1)
  end
end

function do_work()
  r.select(16)
  if r.compareUp() then
    r.swingUp()
  end
  r.select(1)
  r.placeUp()
end

function work()
  for _, pos in ipairs(WORK) do
    go_to(pos.x, pos.y, pos.z)
	do_work()
  end
end

while true do
  go_home()
  prep_inv()
  wait_until_ready()
  work()
end
