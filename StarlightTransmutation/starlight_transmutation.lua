local comp = require("computer")
local com  = require("component")
local t    = require("term")
local os   = require("os")
local r    = require("robot")
local s    = require("sides")
local n    = com.navigation
local inv  = com.inventory_controller

local HOME            = { facing=s.west, x=-15.5, y=130.5, z=52.5 }
local INPUT           = { facing=s.south, name="tile.sandstone.name", damage=0 }
local OUTPUT          = { facings.east, name="tile.end_stone.name", damage=0 }
local ENERGY_TRESHOLD = 0.99
local SIZE            = 3
local WORK            = {}

------------------------------

function fill_work()
  -- assuming HOME is in the south-east corner and
     -- one block below the 3x3 work area
  local y = HOME.y + 1
  for z = 0, 1 - SIZE, -1 do
    local odd   = i % 2 == 1
    local start = if odd then  0        else 1 - SIZE end
    local end_  = if odd then  1 - SIZE else 0        end
    local step  = if odd then -1        else 1        end
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
  for i = 1, n, 1 do
    while not r.forward() do
	  print("Cannot move: path obstructed!")
	  os.sleep(0.25)
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
  rotate_to(HOME.facing)
end

function prep_inv()
  rotate_to(OUTPUT.facing)
  
  for i = 2, 15, 1 do
    r.select(i)
    r.drop()
  end
  
  r.select(16)
  local count = r.count()
  if count > 1
    r.drop(count - 1)
  end
  -----------------------------------------------------------------------------
  rotate_to(INPUT.facing)
  
  r.select(1)
  local space = r.space()
  if space > 0 then
    for i = 1, inv.getInventorySize(s.front), 1 do
      local item = inv.getStackInSlot(s.front, i)
	  if item and item.name == INPUT.name and item.damage == INPUT.damage then
	    if inv.suckFromSlot(s.front, i, space) then
	      space = r.space()
	    end
	    if space == 0 then
	      break
	    end
	  end
    end
  end
  
  for i = 2, 15, 1 do
    r.select(i)
    r.drop()
  end
  -----------------------------------------------------------------------------
  rotate_to(HOME.facing)
end

function not_ready()
  if comp.energy() < ENERGY_TRESHOLD * comp.maxEnergy() then
    print("Missing energy")
    return true
  end
  local facing = n.getFacing()
  if facing ~= HOME.facing then
    print("Wrong facing")
    return false
  end
  local x, y, z = n.getPosition()
  if x ~= HOME.x or y ~= HOME.y or z ~= HOME.z then
    print("Wrong position")
    return false
  end
  local stack = r.getStackInInternalSlot(1)
  if not stack or stack.size < math.min(SIZE * SIZE + 1, stack.maxSize) or stack.name ~= INPUT.name or stack.damage ~= INPUT.damage then
    print("Stack in Slot 1 does not equal INPUT with minimum size " .. math.min(SIZE * SIZE + 1, stack.maxSize))
    return true
  end
  for i = 2, 15, 1 do
    if r.count(i) > 0 do
	  print("Stack in Slot " .. i .. " is not empty")
	  return true
	end
  end
  stack = r.getStackInInternalSlot(16)
  if not stack or stack.size ~= 1 or stack.name ~= OUTPUT.name or stack.damage ~= OUTPUT.damage then
    print("Stack in Slot 16 does not equal OUTPUT with size 1")
    return true
  end
  
  return false
end

function wait_until_ready()
  while not_ready() do
    os.sleep(5)
	go_home()
	prep_inv()
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
	if r.count(1) <= 1 then
	  break
	end
  end
end

while true do
  go_home()
  prep_inv()
  wait_until_ready()
  work()
end
