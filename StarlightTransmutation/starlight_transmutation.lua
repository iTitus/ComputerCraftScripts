local comp = require("computer")
local com  = require("component")
local t    = require("term")
local e    = require("event")
local os   = require("os")
local math = require("math")
local r    = require("robot")
local s    = require("sides")
local n    = com.navigation
local inv  = com.inventory_controller

local HOME            = { facing=s.west , x=-15.5, y=130.5, z=52.5 }
local TOOL            = {                 name="redstonearsenal:tool.pickaxe_flux", damage=0 }
local INPUT           = { facing=s.south, name="minecraft:sandstone"              , damage=0 }
local OUTPUT          = { facing=s.east , name="minecraft:end_stone"              , damage=0 }
local ENERGY_TRESHOLD = 0.99
local SIZE            = 3
local WORK            = {}

local interrupted = false

------------------------------

function fill_work()
  -- assuming HOME is in the south-east corner and
     -- one block below the 3x3 work area
  local y = HOME.y + 1
  for z = 0, 1 - SIZE, -1 do
    local even  = z % 2 == 0
    local start = even and ( 0       ) or (1 - SIZE)
    local end_  = even and ( 1 - SIZE) or (0       )
    local step  = even and (-1       ) or (1       )
    for x = start, end_, step do
      table.insert(WORK, { x=HOME.x+x, y=y, z=HOME.z+z })
    end
  end
end

function on_interrupted(event, ...)
  interrupted = true
  print("Received event interrupt")
end

function on_inventory_change(event, slot)
  if not interrupted and slot == 16 and r.count(16) == 0 then
    interrupted = true
    print("Received interrupt by output item removal")
  end
end

t.clear()
t.setCursor(1, 1)
fill_work()
e.listen("interrupted", on_interrupted)
e.listen("inventory_changed", on_inventory_change)
print("Starlight Transmutation!")
print("Remove the output item from Slot 16 to instantly abort the program")

function rotate_to(side)
  while not interrupted and n.getFacing() ~= side do
    r.turnRight()
  end
end

function move(n, pos_fn, neg_fn)
  if n ~= 0 then
    local fn = n > 0 and pos_fn or neg_fn
    for i = 1, math.abs(n), 1 do
      local success, msg
      repeat
        success, msg = fn()
        if not success then
          print("Cannot move: " .. tostring(msg))
          os.sleep(0.25)
        end
      until interrupted or success
      if interrupted then return end
    end
  end
end

function move_forward(n)
  move(n, r.forward, r.back)
end

function move_up(n)
  move(n, r.up, r.down)
end

function go_to(t_x, t_y, t_z)
  local x, y, z = n.getPosition()
  local d_x, d_y, d_z = t_x - x, t_y - y, t_z - z
  if interrupted then return end
  if d_y ~= 0 then
    move_up(d_y)
  end
  if interrupted then return end
  if d_x ~= 0 then
    local facing_name = (d_x > 0 and "pos" or "neg") .. "x"
    rotate_to(s[facing_name])
    move_forward(math.abs(d_x))
  end
  if interrupted then return end
  if d_z ~= 0 then
    local facing_name = (d_z > 0 and "pos" or "neg") .. "z"
    rotate_to(s[facing_name])
    move_forward(math.abs(d_z))
  end
end

function go_home()
  go_to(HOME.x, HOME.y, HOME.z)
  rotate_to(HOME.facing)
end

function prep_inv()
  rotate_to(HOME.facing)
  
  r.select(8)
  if inv.equip() then
    local tool = inv.getStackInInternalSlot(8)
    if tool and tool.size == 1 and tool.name == TOOL.name and tool.damage == TOOL.damage then
      local success, msg = r.dropDown()
      if not success then
        print("Could not drop tool into charger: " .. msg)
      end
    else
      print("The equipped tool does not match the template")
    end
    inv.equip()
  else
    print("Could not unequip tool")
  end
  -----------------------------------------------------------------------------
  rotate_to(OUTPUT.facing)
  
  for i = 2, 15, 1 do
    r.select(i)
    r.drop()
  end
  
  r.select(16)
  local count = r.count()
  if count > 1 then
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
  
  r.select(8)
  if inv.equip() then
    local tool = inv.getStackInInternalSlot(8)
    if not tool then
      local success, msg = r.suckDown()
      if not success then
        print("Could not suck tool from charger: " .. msg)
      end
    else
      print("Unexpected tool in tool slot")
    end
    inv.equip()
  else
    print("Could not unequip tool")
  end
end

function not_ready()
  -- Energy
  if comp.energy() < ENERGY_TRESHOLD * comp.maxEnergy() then
    print("Missing energy")
    return true
  end
  
  -- Facing
  local facing = n.getFacing()
  if facing ~= HOME.facing then
    print("Wrong facing")
    return false
  end
  
  -- Position
  local x, y, z = n.getPosition()
  if x ~= HOME.x or y ~= HOME.y or z ~= HOME.z then
    print("Wrong position")
    return false
  end
  
  -- Input Item
  local stack = inv.getStackInInternalSlot(1)
  if not stack or stack.maxSize < 2 or stack.size < math.min(SIZE * SIZE + 1, stack.maxSize) or stack.name ~= INPUT.name or stack.damage ~= INPUT.damage then
    print("Stack in Slot 1 does not equal INPUT with minimum size " .. math.min(SIZE * SIZE + 1, stack.maxSize) .. " and a maximum size of at least 2")
    return true
  end
  
  -- Empty in between
  for i = 2, 15, 1 do
    if r.count(i) > 0 then
      print("Stack in Slot " .. i .. " is not empty")
      return true
    end
  end
  
  -- Output Item
  stack = inv.getStackInInternalSlot(16)
  if not stack or stack.size ~= 1 or stack.name ~= OUTPUT.name or stack.damage ~= OUTPUT.damage then
    print("Stack in Slot 16 does not equal OUTPUT with size 1")
    return true
  end
  
  -- Tool
  r.select(8)
  if inv.equip() then
    local tool = inv.getStackInInternalSlot(8)
    inv.equip()
    if not tool or tool.size ~= 1 or tool.name ~= TOOL.name or tool.damage ~= TOOL.damage then
      print("The equipped tool does not match the template")
      return true
    end
  else
    print("Could not unequip tool")
    return true
  end
  
  return false
end

function wait_until_ready()
  while not interrupted and not_ready() do
    os.sleep(5)
    if interrupted then break end
    go_home()
    if interrupted then break end
    prep_inv()
  end
end

function do_work()
  local is_input = false
  local is_output = false
  r.select(1)
  if r.compareUp() then
    is_input = true
  else
    r.select(16)
    if r.compareUp() then
      is_output = true
    end
  end
  
  if is_output then
    local success, msg
    repeat
      success, msg = r.swingUp()
      if not success then
        print("Cannot break block")
        os.sleep(0.25)
      end
    until interrupted or success
  end
  if interrupted then return end
  if not is_input then
    r.select(1)
    local success, msg
    repeat
      success, msg = r.placeUp()
      if not success then
        print("Cannot place block: " .. tostring(msg))
        os.sleep(0.25)
      end
    until interrupted or success
  end
end

function work()
  for _, pos in ipairs(WORK) do
    go_to(pos.x, pos.y, pos.z)
    if interrupted then break end
    do_work()
    if interruped or r.count(1) <= 1 then break end
  end
end

while not interrupted do
  go_home()
  if interrupted then break end
  prep_inv()
  if interrupted then break end
  wait_until_ready()
  if interrupted then break end
  work()
  if interrupted then break end
end
